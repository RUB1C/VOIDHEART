extends Node2D

func _ready() -> void:
	var player = get_node_or_null("Capa_juego/Player")
	if not player:
		return
	var marcador = get_node_or_null("Spawns/" + GameManager.spawn_id)
	if marcador:
		player.global_position = marcador.global_position
