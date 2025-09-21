extends Node

@onready var current_level: Node = $CurrentLevel
@onready var ana: Node = $Ana
@onready var hud: Node = get_node_or_null("HUD")             # CanvasLayer del HUD
@onready var quest: Node = get_node_or_null("QuestManager")  # Manager de objetivos
@onready var dialogic_runner: Node = get_node_or_null("DialogicRunner")

var spawn_name: String = "SpawnAna"
var _last_scene_path: String = ""                 
var _location_was_set_manually: bool = false      

# Nuevas variables para manejar la interacción
var interaction_enabled: bool = true  
var is_dialog_active: bool = false  # Variable que controla si el diálogo está activo.
var jefe_dialogue_completed: bool = false  # Estado del diálogo con el jefe

# Nombres “bonitos” por escena
var location_names := {
	"res://scenes/levels/NivelOficina.tscn": "Oficina Principal",
	"res://scenes/levels/NivelOficinaJefe.tscn": "Oficina del Jefe",
	"res://scenes/levels/NivelComedor.tscn": "Comedor",
	"res://scenes/levels/NivelSalaConserje.tscn": "Sala del Conserje",
	"res://scenes/levels/NivelSalaVigilancia.tscn": "Sala de Vigilancia",
	"res://scenes/levels/NivelSalaJuntas.tscn": "Sala de Juntas",
	"res://scenes/levels/NivelEstudioGrabacion.tscn": "Estudio de Grabación"
}

var location_aliases := {
	"oficina": "Oficina Principal",
	"oficina_jefe": "Oficina del Jefe",
	"comedor": "Comedor",
	"sala_conserje": "Sala del Conserje",
	"sala_vigilancia": "Sala de Vigilancia",
	"sala_juntas": "Sala de Juntas",
	"estudio": "Estudio de Grabación"
}

var scenes := {
	"res://scenes/levels/NivelOficina.tscn": null,
	"res://scenes/levels/NivelOficinaJefe.tscn": null,
	"res://scenes/levels/NivelComedor.tscn": null,
	"res://scenes/levels/NivelSalaConserje.tscn": null,
	"res://scenes/levels/NivelSalaVigilancia.tscn": null,
	"res://scenes/levels/NivelSalaJuntas.tscn": null,
	"res://scenes/levels/NivelEstudioGrabacion.tscn": null
}

var _timeline_cb: Callable = Callable()

var day: int = 1
var time_left: float = 240.0  # 4 minutos (240 segundos)
var game_over: bool = false
var time_progress: float = 1.0  # Barra de progreso del tiempo

# ---------- Dialogic helper ----------
func _ensure_dialogic() -> Node:
	if dialogic_runner:
		return dialogic_runner
	var n := get_node_or_null("Dialogic")
	if n:
		dialogic_runner = n
		return dialogic_runner
	for c in get_children():
		if c.has_method("start"):
			dialogic_runner = c
			return dialogic_runner
	return null

func play_timeline(timeline_name: String, on_finished: Callable = Callable()) -> void:
	hud.visible = false
	is_dialog_active = true  # Marca que el diálogo ha comenzado
	var dlg := _ensure_dialogic()
	if dlg == null:
		push_warning("Dialogic runner not found. Skipping timeline: %s" % timeline_name)
		if on_finished != Callable():
			on_finished.call()
		return

	# Desconectar la señal si ya está conectada
	if dlg.is_connected("timeline_ended", Callable(self, "_on_timeline_end")):
		dlg.disconnect("timeline_ended", Callable(self, "_on_timeline_end"))

	# Ahora conectar la señal
	dlg.connect("timeline_ended", Callable(self, "_on_timeline_end"))

	_timeline_cb = on_finished
	dlg.call("start", timeline_name)


func _on_timeline_end() -> void:
	hud.visible = true
	is_dialog_active = false  # Marca que el diálogo ha terminado
	var cb := _timeline_cb
	_timeline_cb = Callable()
	if cb != Callable():
		cb.call()

# Función para habilitar o deshabilitar la interacción
func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled

# Bloqueo de movimiento de Ana mientras el diálogo esté activo
func set_ana_movement(enabled: bool) -> void:
	if ana and ana.has_method("set_interactable"):
		ana.call("set_interactable", enabled)

func next_day() -> void:
	day += 1
	time_left = 240.0  # Reinicia los 4 minutos para el siguiente día

	# Cambiar la misión después de hablar con Luisa
	if quest.is_current("find_luisa"):
		quest.call("complete", "find_luisa")  # Completa la misión
		quest.call("add_objective", "explore_office", "Tómate el resto del día para conocer las instalaciones y a los trabajadores")
	else:
		# Si la misión ya está completa, puedes añadir nuevas misiones si lo deseas
		pass

	# Verifica si se ha llegado al día 10 para el "Game Over"
	if day > 10:
		game_over = true
		hud.call("set_objective", "¡Has sido descubierto!")  # Muestra el mensaje en el HUD
		print("¡Has sido descubierto! El juego ha terminado.")   
		# Aquí cambiamos a la pantalla de inicio
		get_tree().change_scene("res://scenes/ui/IntroScreen.tscn")  # Redirige al IntroScreen.tscn


func _on_timer_timeout() -> void:
	if game_over:
		return  # No hacer nada si el juego terminó
		
	time_left -= 1
	if time_left <= 0:
		next_day()  # Pasa al siguiente día
	
	update_hud()  # Actualiza la interfaz del usuario

func update_hud() -> void:
	if hud:
		hud.call("set_day", "Day: %d" % day)  # Muestra el día
		hud.call("set_time_left", "Time Left: %.1f" % time_left)  # Muestra el tiempo restante
		time_progress = 1.0 - (time_left / 240.0)  # Calcula el progreso del día
		hud.call("set_progress_bar", time_progress)  # Actualiza la barra de progreso


func _ready() -> void:
	# Oculta a Ana y el contenedor del nivel durante MainMenu/Intro
	if ana is CanvasItem:
		(ana as CanvasItem).visible = false
		if ana.has_node("Camera2D"):
			var cam: Node = ana.get_node("Camera2D")
			if "enabled" in cam:
				cam.set("enabled", false)

	if current_level is CanvasItem:
		(current_level as CanvasItem).visible = false

	if quest:
		if quest.has_signal("objective_changed"):
			quest.connect("objective_changed", Callable(self, "_on_objective_changed"))
		if quest.has_signal("all_objectives_done"):
			quest.connect("all_objectives_done", Callable(self, "_on_all_objectives_done"))

	# **Ocultamos el HUD mientras se está mostrando la pantalla de carga o haya un diálogo activo**
	if hud:
		hud.visible = false  # Ocultar el HUD al inicio (pantalla de carga)
		if is_dialog_active:
			hud.visible = false  # Asegurarnos de que el HUD esté oculto si hay un diálogo activo

	# Conectar la señal de finalización del diálogo de introducción
	var local_dialogic_runner = _ensure_dialogic()
	if local_dialogic_runner:
		local_dialogic_runner.connect("timeline_ended", Callable(self, "_on_intro_dialog_completed"))


# Función para activar el HUD cuando el diálogo de introducción termine
func _on_intro_dialog_completed():
	# Asegura que el HUD se haga visible cuando el diálogo termine
	if hud:
		hud.visible = true  # Mostrar el HUD después de que el diálogo haya terminado

# -------------------------
#  Helpers del HUD (proxy)
# -------------------------
func hud_set_objective(text: String) -> void:
	if hud and hud.has_method("set_objective"):
		hud.call("set_objective", text)

func hud_show_interact(text: String = "[E] Interactuar") -> void:
	if hud and hud.has_method("show_interact"):
		hud.call("show_interact", text)

func hud_hide_interact() -> void:
	if hud and hud.has_method("hide_interact"):
		hud.call("hide_interact")

func hud_set_location(text: String) -> void:
	if hud and hud.has_method("set_location"):
		hud.call("set_location", text)

# --------- Ubicación controlada por puertas / alias ---------
func hud_set_location_alias(alias: String) -> void:
	var fallback: String = alias.capitalize().replace("_", " ")
	var nice: String = String(location_aliases.get(alias, fallback))
	_location_was_set_manually = true
	hud_set_location(nice)

func hud_set_location_by_path(scene_path: String) -> void:
	var nice_from_map: Variant = location_names.get(scene_path, "")
	var nice: String = (nice_from_map as String)
	if nice == "" or nice == null:
		var base: String = scene_path.get_file().get_basename() # p.ej. "NivelOficina"
		nice = base.replace("Nivel", "").replace("_", " ").strip_edges()
	hud_set_location(nice)
# -----------------------------------------------------------

# --------------------------------
#  Helpers del QuestManager (proxy)
# --------------------------------
func quest_set_sequence(seq: Array) -> void:
	if quest and quest.has_method("set_sequence"):
		quest.call("set_sequence", seq)

func quest_start() -> void:
	if quest and quest.has_method("start"):
		quest.call("start")

func quest_complete(id: String) -> void:
	if quest and quest.has_method("complete"):
		quest.call("complete", id)

func quest_skip_to(id: String) -> void:
	if quest and quest.has_method("skip_to"):
		quest.call("skip_to", id)

func quest_add_objective(id: String, text: String) -> void:
	if quest and quest.has_method("add_objective"):
		quest.call("add_objective", id, text)

func quest_add_next(id: String, text: String) -> void:
	if quest and quest.has_method("add_next"):
		quest.call("add_next", id, text)

# Callbacks desde QuestManager para actualizar HUD
func _on_objective_changed(_id: String, text: String, _index: int, _total: int) -> void:
	hud_set_objective(text)

func _on_all_objectives_done() -> void:
	hud_set_objective("")  # o "Objetivos completados"

# --------------------------------
#  Activar juego y carga de nivel
# --------------------------------
func activar_modo_juego() -> void:
	if ana is CanvasItem:
		(ana as CanvasItem).visible = true
		if ana.has_node("Camera2D"):
			var cam: Node = ana.get_node("Camera2D")
			if "enabled" in cam:
				cam.set("enabled", true)

	if current_level is CanvasItem:
		(current_level as CanvasItem).visible = true

# Cargar un nivel desde el diccionario o directamente
func load_level(scene_path: String) -> void:
	# Elimina el nivel actual si existe
	if current_level.get_child_count() > 0:
		current_level.get_child(0).queue_free()

	var scene_res: PackedScene = scenes.get(scene_path, null) as PackedScene
	if scene_res == null:
		scene_res = load(scene_path) as PackedScene

	_last_scene_path = scene_path
	call_deferred("_load_new_scene", scene_res)  # evita conflictos con física

# Instancia nueva escena y coloca a Ana en el punto de aparición
func _load_new_scene(scene_res: PackedScene) -> void:
	var new_scene: Node = scene_res.instantiate()
	current_level.add_child(new_scene)

	var spawn = new_scene.get_node_or_null(spawn_name) # puede ser null
	if spawn and ana:
		if "global_position" in ana and "global_position" in spawn:
			ana.set("global_position", spawn.get("global_position"))

	# Fallback de Location: solo si ninguna puerta ya la fijó manualmente
	if _location_was_set_manually:
		_location_was_set_manually = false
	else:
		hud_set_location_by_path(_last_scene_path)
