extends CharacterBody2D

@export var move_speed: float = 200.0   # Velocidad al caminar
@export var run_multiplier: float = 1.6 # Multiplicador al correr
@export var acceleration: float = 12.0  # Qué tan rápido arranca
@export var friction: float = 12.0      # Qué tan rápido frena

func _physics_process(delta: float) -> void:
	# 1. Obtener las direcciones de entrada en ambos ejes (-1, 0, 1)
	var direction_x := Input.get_axis("izquierda", "derecha")
	var direction_y := Input.get_axis("arriba", "abajo")

	# 2. Determinar si el jugador está corriendo
	var current_speed = move_speed
	if Input.is_action_pressed("correr"):
		current_speed *= run_multiplier

	# Movimiento horizontal
	if direction_x != 0:
		velocity.x = move_toward(velocity.x, direction_x * current_speed, acceleration * (move_speed * delta * 5))
		
		# Voltear el sprite según la dirección horizontal
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.flip_h = direction_x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * (move_speed * delta * 5))

	# Movimiento vertical
	if direction_y != 0:
		velocity.y = move_toward(velocity.y, direction_y * current_speed, acceleration * (move_speed * delta * 5))
	else:
		velocity.y = move_toward(velocity.y, 0, friction * (move_speed * delta * 5))

	# 4. Ejecutar el movimiento físico del motor
	move_and_slide()
