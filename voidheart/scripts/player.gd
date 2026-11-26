extends CharacterBody2D

@export var move_speed: float = 200.0
@export var run_multiplier: float = 1.6
@export var acceleration: float = 14.0
@export var friction: float = 16.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sonido_pasos: AudioStreamPlayer2D = get_node_or_null("SonidoPasos")
@onready var luz_audifonos: PointLight2D = get_node_or_null("LuzAudifonos")

var _tiempo_paso: float = 0.0
var _pulso_luz: float = 0.0

func _ready() -> void:
	_reproducir_animacion("idle")
	_configurar_sonido_pasos()

	if not GameManager.audifonos_estado_cambiado.is_connected(_on_audifonos_estado_cambiado):
		GameManager.audifonos_estado_cambiado.connect(_on_audifonos_estado_cambiado)

	if luz_audifonos:
		luz_audifonos.energy = 1.25 if GameManager.audifonos_activos else 0.0

func _exit_tree() -> void:
	if GameManager.audifonos_estado_cambiado.is_connected(_on_audifonos_estado_cambiado):
		GameManager.audifonos_estado_cambiado.disconnect(_on_audifonos_estado_cambiado)

func _configurar_sonido_pasos() -> void:
	if not sonido_pasos:
		return
	var randomizer = AudioStreamRandomizer.new()
	randomizer.random_pitch = 1.06
	var rutas = [
		"res://assets/audio/sfx/sfx_paso_01.wav",
		"res://assets/audio/sfx/sfx_paso_02.wav",
		"res://assets/audio/sfx/sfx_paso_03.wav",
		"res://assets/audio/sfx/sfx_paso_04.wav"
	]
	for r in rutas:
		if ResourceLoader.exists(r):
			randomizer.add_stream(-1, load(r))
	sonido_pasos.stream = randomizer
	sonido_pasos.volume_db = -10.0

func _on_audifonos_estado_cambiado(activo: bool) -> void:
	if luz_audifonos:
		var tween = create_tween()
		tween.tween_property(luz_audifonos, "energy", 1.25 if activo else 0.0, 0.35)

func _reproducir_animacion(nombre_anim: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(nombre_anim):
		if sprite.animation != nombre_anim or not sprite.is_playing():
			sprite.play(nombre_anim)

func _physics_process(delta: float) -> void:
	if luz_audifonos and GameManager.audifonos_activos:
		_pulso_luz += delta * 2.5
		luz_audifonos.energy = 1.15 + sin(_pulso_luz) * 0.2

	if GameManager.is_dialog or GameManager.esta_en_transicion:
		velocity = Vector2.ZERO
		if sonido_pasos and sonido_pasos.playing:
			sonido_pasos.stop()
		_reproducir_animacion("idle")
		move_and_slide()
		return

	var direction_x := Input.get_axis("izquierda", "derecha")
	var direction_y := Input.get_axis("arriba", "abajo")
	var hay_input := (direction_x != 0.0 or direction_y != 0.0)

	var corriendo := Input.is_action_pressed("correr")
	var current_speed = move_speed
	if corriendo:
		current_speed *= run_multiplier

	if direction_x != 0:
		velocity.x = move_toward(velocity.x, direction_x * current_speed, acceleration * (move_speed * delta * 5))
		if sprite:
			sprite.flip_h = direction_x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * (move_speed * delta * 5))

	if direction_y != 0:
		velocity.y = move_toward(velocity.y, direction_y * current_speed, acceleration * (move_speed * delta * 5))
	else:
		velocity.y = move_toward(velocity.y, 0, friction * (move_speed * delta * 5))

	if velocity.length() > 15.0:
		_reproducir_animacion("caminar")
	else:
		_reproducir_animacion("idle")

	if hay_input and velocity.length() > 25.0 and sonido_pasos:
		_tiempo_paso -= delta
		if _tiempo_paso <= 0.0:
			sonido_pasos.play()
			_tiempo_paso = 0.26 if corriendo else 0.40
	else:
		_tiempo_paso = 0.05
		if not hay_input and sonido_pasos and sonido_pasos.playing:
			sonido_pasos.stop()

	move_and_slide()
