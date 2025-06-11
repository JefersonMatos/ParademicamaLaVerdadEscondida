extends CharacterBody2D

@onready var anim := $AnimatedSprite_Ana

const WALK_SPEED := 100.0       # 🔁 Renombrado
const RUN_SPEED := 180.0        # 🔁 Añadido

func _physics_process(_delta):
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

	var is_running := Input.is_action_pressed("ui_run")  # 🔁 Detecta Shift
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
