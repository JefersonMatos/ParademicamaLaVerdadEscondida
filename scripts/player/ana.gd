extends CharacterBody2D

@onready var anim := $AnimatedSprite_Ana

const WALK_SPEED := 100.0       
const RUN_SPEED := 180.0        

var interaction_enabled := true  # Controla si Ana puede moverse e interactuar

func set_interactable(enabled: bool) -> void:
	interaction_enabled = enabled
	# Si la interacción está deshabilitada, bloqueamos el movimiento
	if not interaction_enabled:
		velocity = Vector2.ZERO  # Detenemos el movimiento

func _ready():
	# Inicialización
	pass

func _physics_process(_delta):
	if not interaction_enabled:
		return  # No permite movimiento si la interacción está deshabilitada

	var dir := Vector2.ZERO

	# Captura teclas de dirección
	if Input.is_action_pressed("ui_right"):
		dir.x = 1
	elif Input.is_action_pressed("ui_left"):
		dir.x = -1
	elif Input.is_action_pressed("ui_down"):
		dir.y = 1
	elif Input.is_action_pressed("ui_up"):
		dir.y = -1

	var is_running := Input.is_action_pressed("ui_run")
	var speed := RUN_SPEED if is_running else WALK_SPEED

	velocity = dir.normalized() * speed
	move_and_slide()

	# Animaciones automáticas según dirección y estado de correr
	if dir != Vector2.ZERO:
		var prefix := "run_" if is_running else "walk_"
		if dir.x > 0:
			anim.play(prefix + "right")
		elif dir.x < 0:
			anim.play(prefix + "left")
		elif dir.y > 0:
			anim.play(prefix + "down")
		elif dir.y < 0:
			anim.play(prefix + "up")
	else:
		match anim.animation:
			"walk_down", "run_down": anim.play("idle_down")
			"walk_up", "run_up": anim.play("idle_up")
			"walk_left", "run_left": anim.play("idle_left")
			"walk_right", "run_right": anim.play("idle_right")
