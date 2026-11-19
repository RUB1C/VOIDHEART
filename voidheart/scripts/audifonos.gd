extends Area2D

@export var nombre_item: String = "Audífonos"

var jugador_en_zona: bool = false
var jugador_referencia: Node2D = null

@onready var indicador_e: Label = $Label

func _ready() -> void:
	if GameManager.tiene_audifonos:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_en_zona = true
		jugador_referencia = body
		indicador_e.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == jugador_referencia:
		jugador_en_zona = false
		jugador_referencia = null
		indicador_e.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_dialog or GameManager.esta_en_transicion:
		return
	if jugador_en_zona and event.is_action_pressed("interactuar"):
		recoger_item()

func recoger_item() -> void:
	print("¡Has recogido: ", nombre_item, "!")
	GameManager.equipar_audifonos()
	queue_free()
