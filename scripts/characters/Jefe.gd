extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Jefe

var _last_branch: String = ""

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("idle_down")
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active:
		return

	# Lógica M21 - confrontation (Máxima prioridad)
	if gs.quest and gs.quest.is_current("confrontation"):
		_last_branch = "confrontation"
		# Asegúrate de crear este diálogo final en Dialogic
		gs.play_timeline("Jefe-confrontation", Callable(self, "_on_dialogue_end"))

	# Lógica M16 - ask_boss2
	elif gs.quest and gs.quest.is_current("ask_boss2"):
		_last_branch = "ask_boss2"
		gs.play_timeline("Jefe-ask_boss2", Callable(self, "_on_dialogue_end"))

	# Lógica M11 - observe_proof_2
	elif gs.quest and gs.quest.is_current("observe_proof_2"):
		_last_branch = "observe_proof_2"
		gs.play_timeline("Jefe-observe_proof_2", Callable(self, "_on_dialogue_end"))

	# Lógica M9: report_agenda
	elif gs.quest and gs.quest.is_current("report_agenda"):
		_last_branch = "report_agenda"
		gs.play_timeline("Jefe-report_agenda", Callable(self, "_on_dialogue_end"))

	# Lógica M7: report_envelope
	elif gs.quest and gs.quest.is_current("report_envelope"):
		_last_branch = "report_envelope"
		gs.play_timeline("Jefe-report_envelope", Callable(self, "_on_dialogue_end"))

	# Lógica M5: ask_boss
	elif gs.quest and gs.quest.is_current("ask_boss"):
		_last_branch = "ask_boss"
		gs.play_timeline("Jefe-ask_boss", Callable(self, "_on_dialogue_end"))

	# Lógica M2: talk_boss (Bienvenida inicial)
	elif gs.quest and gs.quest.is_current("talk_boss"):
		_last_branch = "bienvenida"
		gs.play_timeline("DialogoJefeBienvenida", Callable(self, "_on_dialogue_end"))

	# Diálogo Genérico/Ocupado
	else:
		_last_branch = "ocupado"
		gs.play_timeline("DialogoJefeOcupado", Callable(self, "_on_dialogue_end"))

	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

func _on_dialogue_end() -> void:
	var completed_mission_id = ""
	var trigger_end_game = false # Bandera para saber si mostrar la pantalla final

	match _last_branch:
		"bienvenida":
			completed_mission_id = "talk_boss"
		"ask_boss":
			completed_mission_id = "ask_boss"
		"report_envelope":
			completed_mission_id = "report_envelope"
		"report_agenda":
			completed_mission_id = "report_agenda"
		"observe_proof_2":
			completed_mission_id = "observe_proof_2"
		"ask_boss2":
			completed_mission_id = "ask_boss2"
		# 🟢 NUEVO: Lógica para el final
		"confrontation":
			completed_mission_id = "confrontation"
			trigger_end_game = true # Marcamos que el juego debe terminar

	# Completa la misión si corresponde
	if completed_mission_id != "" and gs.quest:
		gs.quest.complete(completed_mission_id)

	# Si es el final, muestra la pantalla de FIN
	if trigger_end_game:
		if gs.has_method("show_end_screen"):
			gs.show_end_screen()
		# Si NO es el final, restaura el control normal
	else:
		gs.set_interaction_enabled(true)
		gs.set_ana_movement(true)
		_last_branch = ""
