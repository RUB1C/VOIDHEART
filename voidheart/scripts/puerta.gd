extends Area2D

@export_file("*.tscn") var escena_destino: String = ""
@export var spawn_destino: String = "inicio"
@export var es_salida_final: bool = false

var jugador_en_zona: bool = false
@onready var indicador_e: Label = $Label

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_en_zona = true
		indicador_e.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jugador_en_zona = false
		indicador_e.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_dialog or GameManager.esta_en_transicion:
		return
	if jugador_en_zona and event.is_action_pressed("interactuar"):
		if es_salida_final:
			GameManager.mostrar_fin_prototipo()
		elif escena_destino != "":
			GameManager.cambiar_escena(escena_destino, spawn_destino, true)
