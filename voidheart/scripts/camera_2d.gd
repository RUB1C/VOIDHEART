extends Camera2D

# Definimos la altura fija donde quieres que se quede la cámara verticalmente
@export var posicion_y_fija: float = 576.0 

func _process(_delta: float) -> void:
	global_position.x = get_parent().global_position.x
	global_position.y = posicion_y_fija
