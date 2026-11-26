extends Camera2D

@export var posicion_y_fija: float = 180.0 

func _process(delta: float) -> void:
	global_position.x = get_parent().global_position.x
	global_position.y = posicion_y_fija
