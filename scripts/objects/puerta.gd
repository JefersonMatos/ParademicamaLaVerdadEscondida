extends Area2D

@onready var anim := $SpritePuerta
@onready var sonido_abrir := $SonidoAbrir

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Ana":
		anim.play("abrir")
		sonido_abrir.play()

func _on_body_exited(body):
	if body.name == "Ana":
		anim.play("cerrar")
