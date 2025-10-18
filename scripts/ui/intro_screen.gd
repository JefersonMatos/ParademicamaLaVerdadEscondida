extends Control

@onready var dialogic := $Dialogic
@onready var hud = get_node("/root/GameState/HUD")  # Ruta al HUD
@onready var timer = get_node("/root/GameState/Timer")  # Ruta al Timer

func _ready():
	# Conecta primero, luego inicia (evita perder la señal si el timeline es muy corto)
	dialogic.timeline_ended.connect(_on_dialogo_terminado)
	dialogic.start("IntroDialog")

func _on_dialogo_terminado():
	var gs = get_tree().root.get_node("GameState")

	# Inicia el juego y entra a NivelOficina
	gs.activar_modo_juego()
	gs.spawn_name = "SpawnAna"
	hud.visible = true
	gs.load_level("res://scenes/levels/NivelOficina.tscn")
	timer.start()

	# Espera 1 frame porque load_level instancia con call_deferred
	await get_tree().process_frame
