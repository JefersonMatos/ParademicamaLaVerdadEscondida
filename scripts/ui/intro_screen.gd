extends Control

@onready var dialogic := $Dialogic

func _ready():
	# Conecta primero, luego inicia (evita perder la señal si el timeline es muy corto)
	dialogic.timeline_ended.connect(_on_dialogo_terminado)
	dialogic.start("IntroDialog")

func _on_dialogo_terminado():
	var gs = get_tree().root.get_node("GameState")

	# Inicia el juego y entra a NivelOficina
	gs.activar_modo_juego()
	gs.spawn_name = "SpawnAna"
	gs.load_level("res://scenes/levels/NivelOficina.tscn")

	# Espera 1 frame porque load_level instancia con call_deferred
	await get_tree().process_frame

	# Configura la cola de objetivos inicial
	gs.quest_set_sequence([
		{"id":"go_boss_office", "text":"Ve a la oficia del jefe"},
		{"id":"talk_boss",      "text":"Habla con el jefe"}
	])
	gs.quest_start()
