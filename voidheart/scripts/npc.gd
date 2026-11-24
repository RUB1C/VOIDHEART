extends Area2D

@export var ruta_dialogo: String = "res://dialogs/npc_casa.dialogue"
@export var titulo_inicio: String = "start"

var is_player_close: bool = false

@onready var indicador_e: Label = $Label
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if indicador_e:
		indicador_e.visible = false

	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		if not dm.dialogue_started.is_connected(_on_dialogue_started):
			dm.dialogue_started.connect(_on_dialogue_started)
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)

func _exit_tree() -> void:
	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		if dm.dialogue_started.is_connected(_on_dialogue_started):
			dm.dialogue_started.disconnect(_on_dialogue_started)
		if dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.disconnect(_on_dialogue_ended)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_player_close = true
		if not GameManager.is_dialog and indicador_e:
			indicador_e.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		is_player_close = false
		if indicador_e:
			indicador_e.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.esta_en_transicion:
		return

	if is_player_close and not GameManager.is_dialog and event.is_action_pressed("interactuar"):
		get_viewport().set_input_as_handled()
		_iniciar_dialogo()

func _iniciar_dialogo() -> void:
	var dm = get_node_or_null("/root/DialogueManager")
	if dm and ResourceLoader.exists(ruta_dialogo):
		var recurso = load(ruta_dialogo)
		if recurso:
			if indicador_e:
				indicador_e.visible = false
			dm.show_dialogue_balloon(recurso, titulo_inicio)
	else:
		push_warning("No se encontró DialogueManager o el archivo de diálogo en: " + ruta_dialogo)

func _on_dialogue_started(_resource) -> void:
	GameManager.is_dialog = true
	if indicador_e:
		indicador_e.visible = false

func _on_dialogue_ended(_resource) -> void:
	await get_tree().create_timer(0.2).timeout
	GameManager.is_dialog = false
	if is_player_close and indicador_e:
		indicador_e.visible = true
