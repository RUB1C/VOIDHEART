extends Area2D

@export var ruta_dialogo: String = "res://dialogs/npc_casa.dialogue"
@export var titulo_inicio: String = "start"

var is_player_close: bool = false

@onready var indicador_e: Label = $Label
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _fallback_layer: CanvasLayer = null
var _fallback_nombre: Label = null
var _fallback_texto: RichTextLabel = null
var _fallback_opciones: VBoxContainer = null
var _lineas_fallback: Array = []
var _indice_fallback: int = 0
var _esperando_opcion: bool = false

func _ready() -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		if not dm.dialogue_started.is_connected(_on_dialogue_started):
			dm.dialogue_started.connect(_on_dialogue_started)
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_player_close = true
		indicador_e.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_player_close = false
		indicador_e.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.esta_en_transicion:
		return

	if _fallback_layer and _fallback_layer.visible and not _esperando_opcion:
		if event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			_avanzar_fallback()
		return

	if is_player_close and not GameManager.is_dialog and event.is_action_pressed("interactuar"):
		get_viewport().set_input_as_handled()
		_iniciar_dialogo()

func _iniciar_dialogo() -> void:
	var dm = get_node_or_null("/root/DialogueManager")
	if dm and ResourceLoader.exists(ruta_dialogo):
		var recurso = load(ruta_dialogo)
		if recurso:
			indicador_e.visible = false
			dm.show_dialogue_balloon(recurso, titulo_inicio)
			return

	_iniciar_fallback()

func _on_dialogue_started(_resource) -> void:
	GameManager.is_dialog = true

func _on_dialogue_ended(_resource) -> void:
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialog = false
	if is_player_close:
		indicador_e.visible = true

func _crear_fallback_ui() -> void:
	_fallback_layer = CanvasLayer.new()
	_fallback_layer.layer = 50
	add_child(_fallback_layer)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 80
	panel.offset_right = -80
	panel.offset_top = -185
	panel.offset_bottom = -25

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.071, 0.102, 0.94)
	style.border_color = Color(0.486, 0.62, 0.698, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", style)
	_fallback_layer.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	_fallback_nombre = Label.new()
	_fallback_nombre.add_theme_font_size_override("font_size", 20)
	_fallback_nombre.add_theme_color_override("font_color", Color(0.486, 0.62, 0.698, 1.0))
	vbox.add_child(_fallback_nombre)

	_fallback_texto = RichTextLabel.new()
	_fallback_texto.fit_content = true
	_fallback_texto.add_theme_font_size_override("normal_font_size", 18)
	_fallback_texto.add_theme_color_override("default_color", Color(0.88, 0.91, 0.94, 1.0))
	vbox.add_child(_fallback_texto)

	_fallback_opciones = VBoxContainer.new()
	_fallback_opciones.add_theme_constant_override("separation", 6)
	vbox.add_child(_fallback_opciones)

func _iniciar_fallback() -> void:
	if not _fallback_layer:
		_crear_fallback_ui()
	GameManager.is_dialog = true
	indicador_e.visible = false
	_esperando_opcion = false
	_indice_fallback = 0

	if not GameManager.hablo_con_npc:
		GameManager.hablo_con_npc = true
		_lineas_fallback = [
			{"hablante": "???", "texto": "¿A dónde vas tan temprano?"},
			{"hablante": "Protagonista", "texto": "Al colegio. ¿Acaso olvidas que estudio?"},
			{"hablante": "???", "texto": "No lo olvido... solo me sorprende verte salir a esta hora."},
			{"hablante": "???", "texto": "Te recomiendo que vayas con cuidado. He escuchado ciertas cosas sobre ti.", "opciones": [
				{"texto": "¡¿Qué cosas?! ¡No te metas en mi vida!", "respuesta": "Justamente eso... te enojas por cualquier cosa.", "delta_estres": 5.0},
				{"texto": "La verdad, no me importa lo que digan. Solo trato de mantenerme tranquilo.", "respuesta": "Eso está bien. Sigue así.", "delta_estres": -5.0}
			]}
		]
	else:
		_lineas_fallback = [
			{"hablante": "???", "texto": "Ten cuidado allá afuera."}
		]

	_fallback_layer.visible = true
	_mostrar_linea_fallback()

func _mostrar_linea_fallback() -> void:
	for c in _fallback_opciones.get_children():
		c.queue_free()

	if _indice_fallback >= _lineas_fallback.size():
		_cerrar_fallback()
		return

	var item = _lineas_fallback[_indice_fallback]
	_fallback_nombre.text = item["hablante"]
	_fallback_texto.text = item["texto"]

	if item.has("opciones"):
		_esperando_opcion = true
		for op in item["opciones"]:
			var btn = Button.new()
			btn.text = "> " + op["texto"]
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.add_theme_font_size_override("font_size", 16)
			btn.pressed.connect(func(): _elegir_opcion_fallback(op["respuesta"], op.get("delta_estres", 0.0)))
			_fallback_opciones.add_child(btn)
		if _fallback_opciones.get_child_count() > 0:
			_fallback_opciones.get_child(0).grab_focus()
	else:
		_esperando_opcion = false

func _elegir_opcion_fallback(respuesta: String, delta_estres: float = 0.0) -> void:
	if delta_estres != 0.0:
		GameManager.cambiar_estres(delta_estres)
	_esperando_opcion = false
	_lineas_fallback = [{"hablante": "???", "texto": respuesta}]
	_indice_fallback = 0
	_mostrar_linea_fallback()

func _avanzar_fallback() -> void:
	_indice_fallback += 1
	_mostrar_linea_fallback()

func _cerrar_fallback() -> void:
	_fallback_layer.visible = false
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialog = false
	if is_player_close:
		indicador_e.visible = true
