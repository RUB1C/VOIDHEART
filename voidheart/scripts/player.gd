extends CharacterBody2D

@export var move_speed: float = 200.0   # Velocidad al caminar
@export var run_multiplier: float = 1.6 # Multiplicador al correr (opcional para huir)
@export var acceleration: float = 12.0  # Qué tan rápido arranca
@export var friction: float = 12.0      # Qué tan rápido frena

func _physics_process(delta: float) -> void:
	# 1. Obtener la dirección de entrada horizontal (-1 izq, 1 der, 0 quieto)
	var direction := Input.get_axis("izquierda", "derecha")

	# 2. Determinar si el jugador está corriendo (ej. manteniendo presionada la tecla Shift)
	var current_speed = move_speed
	if Input.is_action_pressed("correr"): # Asegúrate de configurar estas acciones si usas correr
		current_speed *= run_multiplier

	# 3. Aplicar movimiento horizontal con aceleración y fricción suave
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * current_speed, acceleration * (move_speed * delta * 5))
		
		# Voltear el sprite según la dirección en la que camina
		
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * (move_speed * delta * 5))

	# 4. Ejecutar el movimiento
	move_and_slide()
