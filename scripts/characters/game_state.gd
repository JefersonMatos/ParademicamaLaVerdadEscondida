extends Node

@onready var current_level: Node = $CurrentLevel
@onready var ana: Node = $Ana
@onready var hud: Node = get_node_or_null("HUD")             # CanvasLayer del HUD
@onready var quest: Node = get_node_or_null("QuestManager")  # Manager de objetivos

# (Opcional) Coloca un DialogicGameHandler como hijo de GameState y nómbralo "DialogicRunner"
@onready var dialogic_runner: Node = get_node_or_null("DialogicRunner")

var spawn_name: String = "SpawnAna"
var _last_scene_path: String = ""                 # para fallback de ubicación
var _location_was_set_manually: bool = false      # evita que el fallback pise lo que puso la puerta

# Nombres “bonitos” por escena (fallback)
var location_names := {
	"res://scenes/levels/NivelOficina.tscn": "Oficina Principal",
	"res://scenes/levels/NivelOficinaJefe.tscn": "Oficina del Jefe",
	"res://scenes/levels/NivelComedor.tscn": "Comedor",
	"res://scenes/levels/NivelSalaConserje.tscn": "Sala del Conserje",
	"res://scenes/levels/NivelSalaVigilancia.tscn": "Sala de Vigilancia",
	"res://scenes/levels/NivelSalaJuntas.tscn": "Sala de Juntas",
	"res://scenes/levels/NivelEstudioGrabacion.tscn": "Estudio de Grabación"
}

# Alias para puertas (IDs simples)
var location_aliases := {
	"oficina": "Oficina Principal",
	"oficina_jefe": "Oficina del Jefe",
	"comedor": "Comedor",
	"sala_conserje": "Sala del Conserje",
	"sala_vigilancia": "Sala de Vigilancia",
	"sala_juntas": "Sala de Juntas",
	"estudio": "Estudio de Grabación"
}

# Referencias a escenas (pueden quedar en null si no precargas)
var scenes := {
	"res://scenes/levels/NivelOficina.tscn": null,
	"res://scenes/levels/NivelOficinaJefe.tscn": null,
	"res://scenes/levels/NivelComedor.tscn": null,
	"res://scenes/levels/NivelSalaConserje.tscn": null,
	"res://scenes/levels/NivelSalaVigilancia.tscn": null,
	"res://scenes/levels/NivelSalaJuntas.tscn": null,
	"res://scenes/levels/NivelEstudioGrabacion.tscn": null
}

# ---------- Dialogic helper ----------
var _timeline_cb: Callable = Callable()

func _ensure_dialogic() -> Node:
	# 1) Usa el runner declarado
	if dialogic_runner:
		return dialogic_runner
	# 2) Busca por nombre común "Dialogic"
	var n := get_node_or_null("Dialogic")
	if n:
		dialogic_runner = n
		return dialogic_runner
	# 3) Busca un hijo que tenga método "start" (DialogicGameHandler)
	for c in get_children():
		if c.has_method("start"):
			dialogic_runner = c
			return dialogic_runner
	return null

func play_timeline(timeline_name: String, on_finished: Callable = Callable()) -> void:
	var dlg := _ensure_dialogic()
	if dlg == null:
		push_warning("Dialogic runner not found. Skipping timeline: %s" % timeline_name)
		if on_finished != Callable():
			on_finished.call()
		return
	# Conecta una sola vez
	if dlg.has_signal("timeline_ended"):
		if dlg.is_connected("timeline_ended", Callable(self, "_on_timeline_end")):
			dlg.disconnect("timeline_ended", Callable(self, "_on_timeline_end"))
		dlg.connect("timeline_ended", Callable(self, "_on_timeline_end"))
	_timeline_cb = on_finished
	dlg.call("start", timeline_name)

func _on_timeline_end() -> void:
	# Desconecta para evitar llamadas duplicadas
	var dlg := _ensure_dialogic()
	if dlg and dlg.has_signal("timeline_ended") and dlg.is_connected("timeline_ended", Callable(self, "_on_timeline_end")):
		dlg.disconnect("timeline_ended", Callable(self, "_on_timeline_end"))
	# Ejecuta callback si hay
	var cb := _timeline_cb
	_timeline_cb = Callable()
	if cb != Callable():
		cb.call()
# -------------------------------------

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

	# Conecta QuestManager → HUD (cambios de objetivo)
	if quest:
		if quest.has_signal("objective_changed"):
			quest.connect("objective_changed", Callable(self, "_on_objective_changed"))
		if quest.has_signal("all_objectives_done"):
			quest.connect("all_objectives_done", Callable(self, "_on_all_objectives_done"))

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
