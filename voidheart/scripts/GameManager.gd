extends Node

signal audifonos_equipados
signal audifonos_estado_cambiado(activo: bool)
signal estres_cambiado(nuevo_valor: float)

var tiene_audifonos: bool = false
var audifonos_activos: bool = false
var estres: float = 35.0
const ESTRES_MIN: float = 0.0
const ESTRES_MAX: float = 100.0

const DURACION_AUDIFONOS: float = 5.0
const REDUCCION_TOTAL_AUDIFONOS: float = 10.0
const COOLDOWN_AUDIFONOS: float = 10.0

var _tiempo_uso_restante: float = 0.0
var _tiempo_cooldown_restante: float = 0.0

var is_dialog: bool = false
var hablo_con_npc: bool = false
var esta_en_transicion: bool = false
var spawn_id: String = "inicio"
var prototipo_finalizado: bool = false

var _capa_transicion: CanvasLayer
var _rect_negro: ColorRect
var _label_fin: Label
var _sfx_player: AudioStreamPlayer

# HUD de Estrés y Audífonos
var _capa_hud: CanvasLayer
var _barra_estres: ProgressBar
var _fill_barra: StyleBoxFlat
var _label_estres: Label
var _label_audifonos: Label

func _ready() -> void:
	_crear_hud()
	_crear_transicion()
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	_actualizar_hud()

func _crear_hud() -> void:
	_capa_hud = CanvasLayer.new()
	_capa_hud.layer = 20
	add_child(_capa_hud)

	var panel = PanelContainer.new()
	panel.position = Vector2(20, 18)
	panel.custom_minimum_size = Vector2(270, 0)
	var style_panel = StyleBoxFlat.new()
	style_panel.bg_color = Color(0.043, 0.055, 0.078, 0.82)
	style_panel.border_color = Color(0.486, 0.62, 0.698, 0.55)
	style_panel.set_border_width_all(1)
	style_panel.set_corner_radius_all(6)
	style_panel.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style_panel)
	_capa_hud.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	_label_estres = Label.new()
	_label_estres.text = "ESTRÉS: 35%"
	_label_estres.add_theme_font_size_override("font_size", 14)
	_label_estres.add_theme_color_override("font_color", Color(0.84, 0.89, 0.94, 1.0))
	vbox.add_child(_label_estres)

	_barra_estres = ProgressBar.new()
	_barra_estres.min_value = ESTRES_MIN
	_barra_estres.max_value = ESTRES_MAX
	_barra_estres.value = estres
	_barra_estres.show_percentage = false
	_barra_estres.custom_minimum_size = Vector2(246, 14)

	var bg_bar = StyleBoxFlat.new()
	bg_bar.bg_color = Color(0.11, 0.14, 0.19, 1.0)
	bg_bar.set_corner_radius_all(4)
	_barra_estres.add_theme_stylebox_override("background", bg_bar)

	_fill_barra = StyleBoxFlat.new()
	_fill_barra.bg_color = Color(0.486, 0.62, 0.698, 1.0)
	_fill_barra.set_corner_radius_all(4)
	_barra_estres.add_theme_stylebox_override("fill", _fill_barra)
	vbox.add_child(_barra_estres)

	_label_audifonos = Label.new()
	_label_audifonos.text = "Audífonos: No recogidos"
	_label_audifonos.add_theme_font_size_override("font_size", 12)
	_label_audifonos.add_theme_color_override("font_color", Color(0.55, 0.62, 0.70, 0.9))
	vbox.add_child(_label_audifonos)

func _crear_transicion() -> void:
	_capa_transicion = CanvasLayer.new()
	_capa_transicion.layer = 100
	add_child(_capa_transicion)

	_rect_negro = ColorRect.new()
	_rect_negro.color = Color(0.043, 0.055, 0.078, 1.0)
	_rect_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect_negro.modulate.a = 0.0
	_capa_transicion.add_child(_rect_negro)

	_label_fin = Label.new()
	_label_fin.text = "VOIDHEART\n\nFin del Prototipo — Día 1\n\n[Presiona R para reiniciar]"
	_label_fin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_fin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label_fin.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label_fin.add_theme_font_size_override("font_size", 28)
	_label_fin.add_theme_color_override("font_color", Color(0.486, 0.62, 0.698, 1.0))
	_label_fin.visible = false
	_capa_transicion.add_child(_label_fin)

func _process(delta: float) -> void:
	if prototipo_finalizado or esta_en_transicion:
		return

	if audifonos_activos:
		var paso = minf(delta, _tiempo_uso_restante)
		_tiempo_uso_restante -= paso
		var tasa = REDUCCION_TOTAL_AUDIFONOS / DURACION_AUDIFONOS
		cambiar_estres(-tasa * paso)

		if _tiempo_uso_restante <= 0.0:
			audifonos_activos = false
			_tiempo_uso_restante = 0.0
			_tiempo_cooldown_restante = COOLDOWN_AUDIFONOS
			audifonos_estado_cambiado.emit(false)
		_actualizar_hud()
	elif _tiempo_cooldown_restante > 0.0:
		_tiempo_cooldown_restante = maxf(0.0, _tiempo_cooldown_restante - delta)
		_actualizar_hud()

func _unhandled_input(event: InputEvent) -> void:
	if prototipo_finalizado and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		reiniciar_prototipo()
		return
	if not prototipo_finalizado and not is_dialog and not esta_en_transicion:
		if tiene_audifonos and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q:
			usar_audifonos()

func cambiar_estres(delta_valor: float) -> void:
	var nuevo = clampf(estres + delta_valor, ESTRES_MIN, ESTRES_MAX)
	if not is_equal_approx(nuevo, estres):
		estres = nuevo
		estres_cambiado.emit(estres)
		_actualizar_hud()

func _actualizar_hud() -> void:
	if not _barra_estres:
		return
	_barra_estres.value = estres
	_label_estres.text = "ESTRÉS: %d%%" % int(round(estres))

	if estres >= 70.0:
		_fill_barra.bg_color = Color(0.75, 0.25, 0.28, 1.0)
	elif estres >= 45.0:
		_fill_barra.bg_color = Color(0.76, 0.56, 0.30, 1.0)
	else:
		_fill_barra.bg_color = Color(0.486, 0.62, 0.698, 1.0)

	if not tiene_audifonos:
		_label_audifonos.text = "Audífonos: No recogidos"
		_label_audifonos.add_theme_color_override("font_color", Color(0.55, 0.62, 0.70, 0.85))
	elif audifonos_activos:
		_label_audifonos.text = "Audífonos: ACTIVOS (%.1fs)" % _tiempo_uso_restante
		_label_audifonos.add_theme_color_override("font_color", Color(0.486, 0.78, 0.88, 1.0))
	elif _tiempo_cooldown_restante > 0.0:
		_label_audifonos.text = "Audífonos: Enfriando (%.0fs)" % ceil(_tiempo_cooldown_restante)
		_label_audifonos.add_theme_color_override("font_color", Color(0.76, 0.56, 0.30, 0.95))
	else:
		_label_audifonos.text = "Audífonos: Listos [Q para usar -10%]"
		_label_audifonos.add_theme_color_override("font_color", Color(0.72, 0.80, 0.86, 0.95))

func reproducir_sfx(ruta_audio: String, volumen_db: float = -6.0) -> void:
	if ResourceLoader.exists(ruta_audio):
		_sfx_player.stream = load(ruta_audio)
		_sfx_player.volume_db = volumen_db
		_sfx_player.play()

func equipar_audifonos() -> void:
	tiene_audifonos = true
	audifonos_activos = false
	_tiempo_uso_restante = 0.0
	_tiempo_cooldown_restante = 0.0
	reproducir_sfx("res://assets/audio/sfx/sfx_equipar_audifonos.wav", -6.0)
	audifonos_equipados.emit()
	_actualizar_hud()

func usar_audifonos() -> void:
	if not tiene_audifonos or audifonos_activos or _tiempo_cooldown_restante > 0.0:
		return
	audifonos_activos = true
	_tiempo_uso_restante = DURACION_AUDIFONOS
	reproducir_sfx("res://assets/audio/sfx/sfx_equipar_audifonos.wav", -9.0)
	audifonos_estado_cambiado.emit(true)
	_actualizar_hud()

func cambiar_escena(ruta_escena: String, nuevo_spawn: String = "inicio", reproducir_puerta: bool = true) -> void:
	if esta_en_transicion:
		return
	esta_en_transicion = true
	spawn_id = nuevo_spawn

	if reproducir_puerta:
		reproducir_sfx("res://assets/audio/sfx/sfx_abrir_puerta.wav", -8.0)

	var tween_out = create_tween()
	tween_out.tween_property(_rect_negro, "modulate:a", 1.0, 0.45)
	await tween_out.finished

	get_tree().change_scene_to_file(ruta_escena)
	await get_tree().process_frame
	await get_tree().process_frame

	var tween_in = create_tween()
	tween_in.tween_property(_rect_negro, "modulate:a", 0.0, 0.45)
	await tween_in.finished

	esta_en_transicion = false

func mostrar_fin_prototipo() -> void:
	if esta_en_transicion:
		return
	esta_en_transicion = true
	_capa_hud.visible = false
	reproducir_sfx("res://assets/audio/sfx/sfx_abrir_puerta.wav", -8.0)

	var tween_out = create_tween()
	tween_out.tween_property(_rect_negro, "modulate:a", 1.0, 0.6)
	await tween_out.finished

	_label_fin.visible = true
	prototipo_finalizado = true

func reiniciar_prototipo() -> void:
	prototipo_finalizado = false
	_label_fin.visible = false
	tiene_audifonos = false
	audifonos_activos = false
	_tiempo_uso_restante = 0.0
	_tiempo_cooldown_restante = 0.0
	estres = 35.0
	hablo_con_npc = false
	is_dialog = false
	spawn_id = "inicio"
	_capa_hud.visible = true
	_actualizar_hud()
	get_tree().change_scene_to_file("res://scenes/levels/habitacion.tscn")
	await get_tree().process_frame
	var tween_in = create_tween()
	tween_in.tween_property(_rect_negro, "modulate:a", 0.0, 0.45)
	await tween_in.finished
	esta_en_transicion = false
