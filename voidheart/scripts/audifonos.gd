extends Area2D

@export var nombre_item: String = "Audífonos"

var jugador_en_zona: bool = false
var jugador_referencia: Node2D = null

# Referencia al Label que acabamos de crear (asegúrate de que sea hijo directo y se llame Label)
@onready var indicador_e: Label = $Label

# 1. Cuando el jugador entra al área de los audífonos
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_en_zona = true
		jugador_referencia = body
		indicador_e.visible = true

# 2. Cuando el jugador se aleja del área
func _on_body_exited(body: Node2D) -> void:
	if body == jugador_referencia:
		jugador_en_zona = false
		jugador_referencia = null
		indicador_e.visible = false

# 3. Detectar la pulsación de la tecla 'E' para recoger sin diálogos
func _unhandled_input(event: InputEvent) -> void:
	if jugador_en_zona and event.is_action_pressed("interactuar"):
		recoger_item()

func recoger_item() -> void:
	print("¡Has recogido: ", nombre_item, "!")
	
	# Aquí puedes añadir la lógica para sumar al inventario o cambiar estados del juego
	
	# Elimina el objeto de la escena por completo
	queue_free()
