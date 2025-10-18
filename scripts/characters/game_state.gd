extends Node

@onready var current_level: Node = $CurrentLevel
@onready var ana: Node = $Ana
@onready var hud: Node = get_node_or_null("HUD")
@onready var quest: Node = get_node_or_null("QuestManager")
@onready var dialogic_runner: Node = get_node_or_null("DialogicRunner")

var spawn_name: String = "SpawnAna"

# Variable para guardar la posición de Ana antes de recargar.
var _reload_ana_position: Vector2 = Vector2.INF # Usamos INF como valor "inválido"

var _last_scene_path: String = ""
var _location_was_set_manually: bool = false

var transition_scene = preload("res://scenes/ui/transicion_dia.tscn")

var interaction_enabled: bool = true
var is_dialog_active: bool = false

var day: int = 1
var time_left: float = 240.0
var game_over: bool = false
var time_progress: float = 1.0

var _timeline_cb: Callable = Callable()

# Diccionarios de escenas (sin cambios)
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

func _ready() -> void:
	# Oculta a Ana y el nivel durante MainMenu/Intro
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

	if hud:
		hud.visible = false

	var local_dialogic_runner = _ensure_dialogic()
	if local_dialogic_runner:
		local_dialogic_runner.connect("timeline_ended", Callable(self, "_on_intro_dialog_completed"))

	# Inicializa y comienza la secuencia de misiones al inicio del juego.
	_initialize_quests()
	quest.start()

# 🟢 AGREGADO: Centraliza toda la secuencia de misiones.
func _initialize_quests() -> void:
	var mission_sequence = [
		# Día 1
		{"id": "talk_boss", "text": "Habla con el jefe"},
		{"id": "find_luisa", "text": "Busca a Luisa"},
		{"id": "explore_office", "text": "Explora las instalaciones y conversa con los trabajadores"},
		# Día 2 en adelante
		{"id": "ask_boss", "text": "Pregúntale al jefe por los pendientes del día"},
		{"id": "deliver_mysterious_envelope", "text": "Entrega el SOBRE MISTERIOSO a Sergio"},
		{"id": "report_envelope", "text": "Reporta al Jefe la entrega del sobre"},
		{"id": "search_proof_1", "text": "Accede a la computadora del jefe para organizar su agenda"},
		{"id": "report_agenda", "text": "Avisa al jefe que terminaste"},
		{"id": "find_carla", "text": "Busca a Carla"},
		{"id": "observe_proof_2", "text": "Reúnete con el Jefe y Carla"},
		{"id": "go_to_janitor", "text": "Ve al cuarto del conserje"},
		{"id": "search_proof_3", "text": "Busca en las cajas"}, # Prueba 3
		{"id": "talk_to_miguel", "text": "Habla con Miguel sobre la bitácora encontrada"},
		{"id": "wait_for_opportunity", "text": "Esperemos la oportunidad de conseguir pistas"},
		# Día siguiente
		{"id": "ask_boss2", "text": "Pregúntale al jefe por los pendientes del día"},
		{"id": "boss_needs_sergio", "text": "Busca a Sergio"},
		{"id": "extract_proof_4", "text": "Descarga las grabaciones de la sala de vigilancia"}, # Prueba 4
		{"id": "meet_miguel_again", "text": "Reunete con Miguel"},
		{"id": "convince_carla", "text": "Muestra las pruebas a Carla y convéncela de testificar"}, # Prueba 5
		{"id": "confrontation", "text": "Confronta a Victor"} # Desenlace
	]
	quest.set_sequence(mission_sequence)

# ---------- Dialogic helper (sin cambios) ----------
func _ensure_dialogic() -> Node:
	if dialogic_runner: return dialogic_runner
	var n := get_node_or_null("Dialogic")
	if n: dialogic_runner = n; return dialogic_runner
	for c in get_children():
		if c.has_method("start"): dialogic_runner = c; return dialogic_runner
	return null

func play_timeline(timeline_name: String, on_finished: Callable = Callable()) -> void:
	hud.visible = false
	is_dialog_active = true
	var dlg := _ensure_dialogic()
	if dlg == null:
		push_warning("Dialogic runner not found. Skipping timeline: %s" % timeline_name)
		if on_finished.is_valid(): on_finished.call()
		return
	if dlg.is_connected("timeline_ended", Callable(self, "_on_timeline_end")):
		dlg.disconnect("timeline_ended", Callable(self, "_on_timeline_end"))
	dlg.connect("timeline_ended", Callable(self, "_on_timeline_end"))
	_timeline_cb = on_finished
	dlg.call("start", timeline_name)

func _on_timeline_end() -> void:
	hud.visible = true
	is_dialog_active = false
	var cb := _timeline_cb
	_timeline_cb = Callable()
	if cb.is_valid(): cb.call()

# ----- Control de Jugador y Día (con cambios) -----
func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled

func set_ana_movement(enabled: bool) -> void:
	if ana and ana.has_method("set_interactable"):
		ana.call("set_interactable", enabled)

func next_day() -> void:
	day += 1
	time_left = 240.0
	if day > 10:
		game_over = true
		hud_set_objective("¡Has sido descubierto!")
		get_tree().change_scene_to_packed(preload("res://scenes/ui/IntroScreen.tscn"))
		return
	spawn_name = "SpawnAna"
	hud.visible = false
	show_day_transition()
	call_deferred("load_level", "res://scenes/levels/NivelOficina.tscn")

func show_day_transition() -> void:
	var transition_instance = transition_scene.instantiate()
	get_tree().root.add_child(transition_instance)
	transition_instance.get_node("ColorRect/Label").text = "Día " + str(day)
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	transition_instance.queue_free()
	hud.visible = true

func _on_timer_timeout() -> void:
	if game_over:
		return

	# El tiempo SIEMPRE disminuye, sin importar el diálogo.
	time_left -= 1

	# Comprobamos si se acabó el tiempo.
	if time_left <= 0:
		# ANTES de cambiar de día, verificamos si hay un diálogo.
		if is_dialog_active:
			# Si hay diálogo, congelamos el tiempo en 1 segundo hasta que termine.
			time_left = 1.0
		else:
			# Si NO hay diálogo, procedemos a la lógica normal de fin de día.
			if day == 1:
				if quest and quest.is_current("explore_office"):
					quest.complete("explore_office")
					next_day()
				else:
					time_left = 1.0 # Congela si la misión no es correcta
			elif day > 1:
				# Comprobar si hay que completar M15 antes de pasar de día.
				if quest and quest.is_current("wait_for_opportunity"):
					quest.complete("wait_for_opportunity")
					# El QuestManager activará automáticamente 'ask_boss2'.
				
				# Pasa al siguiente día.
				next_day()

	update_hud()

func update_hud() -> void:
	if hud:
		hud.set_day(day)
		time_progress = 1.0 - (time_left / 240.0)
		hud.set_progress_bar(time_progress)

func _on_intro_dialog_completed():
	if hud:
		hud.visible = true

# ---------- Helpers del HUD (sin cambios) ----------
func hud_set_objective(text: String) -> void:
	if hud: hud.set_objective(text)
func hud_show_interact(text: String = "[E] Interactuar") -> void:
	if hud: hud.show_interact(text)
func hud_hide_interact() -> void:
	if hud: hud.hide_interact()
func hud_set_location(text: String) -> void:
	if hud: hud.set_location(text)
func hud_set_location_alias(alias: String) -> void:
	var fallback: String = alias.capitalize().replace("_", " ")
	var nice: String = String(location_aliases.get(alias, fallback))
	_location_was_set_manually = true
	hud_set_location(nice)
func hud_set_location_by_path(scene_path: String) -> void:
	var nice_from_map: Variant = location_names.get(scene_path, "")
	var nice = (nice_from_map as String) if nice_from_map is String else ""
	if nice.is_empty():
		var base: String = scene_path.get_file().get_basename()
		nice = base.replace("Nivel", "").replace("_", " ").strip_edges()
	hud_set_location(nice)

# ---------- Callbacks de QuestManager (sin cambios) ----------
func _on_objective_changed(_id: String, text: String, _index: int, _total: int) -> void:
	hud_set_objective(text)
func _on_all_objectives_done() -> void:
	hud_set_objective("")

# ---------- Carga de Nivel (sin cambios) ----------
func activar_modo_juego() -> void:
	if ana is CanvasItem:
		(ana as CanvasItem).visible = true
		if ana.has_node("Camera2D"):
			var cam: Node = ana.get_node("Camera2D")
			if "enabled" in cam: cam.set("enabled", true)
	if current_level is CanvasItem:
		(current_level as CanvasItem).visible = true

func load_level(scene_path: String) -> void:
	if current_level.get_child_count() > 0:
		current_level.get_child(0).queue_free()
	var scene_res = scenes.get(scene_path, null)
	if scene_res == null:
		scene_res = load(scene_path)
	_last_scene_path = scene_path
	call_deferred("_load_new_scene", scene_res)

func _load_new_scene(scene_res: PackedScene) -> void:
	var new_scene: Node = scene_res.instantiate()
	current_level.add_child(new_scene)

	# Lógica para colocar a Ana.
	if ana:
		# 1. ¿Hay una posición guardada de la recarga?
		if _reload_ana_position != Vector2.INF:
			ana.global_position = _reload_ana_position
			# ¡Importante! Limpiar la posición guardada para la próxima carga.
			_reload_ana_position = Vector2.INF 
		# 2. Si no, usa el spawn_name normal.
		else:
			var spawn = new_scene.get_node_or_null(spawn_name)
			if spawn and "global_position" in spawn:
				ana.global_position = spawn.global_position
	if not _location_was_set_manually:
		hud_set_location_by_path(_last_scene_path)
	_location_was_set_manually = false

# Función para recargar la escena con transición negra.
# La función ahora debe ser 'async' para usar 'await' con los Tweens.
func reload_current_scene_with_transition() -> void:
	if _last_scene_path.is_empty():
		push_warning("No hay _last_scene_path para recargar.")
		return
		
	if hud:
		hud.visible = false

	# Instancia la escena de transición
	var transition_instance = transition_scene.instantiate()
	#    OBTENER EL NODO A ANIMAR: Asumimos que es un ColorRect en la raíz o un hijo directo.
	var fade_rect = transition_instance.get_node_or_null("ColorRect") 
	if not fade_rect:
		push_error("Nodo 'ColorRect' no encontrado en transition_scene. No se puede hacer fade.")
		transition_instance.queue_free() # Limpiar si no podemos animar
		load_level(_last_scene_path) # Carga normal sin fade como fallback
		return

	# CONFIGURACIÓN INICIAL: Empieza totalmente transparente.
	fade_rect.modulate.a = 0.0 
	var label = fade_rect.get_node_or_null("Label") # Asumiendo que el Label es hijo del ColorRect
	if label:
		label.text = "" # Sin texto

	# Añade la transición (aún transparente) al árbol de escenas.
	get_tree().root.add_child(transition_instance)

	# Guarda la posición de Ana ANTES de cualquier espera.
	if ana:
		_reload_ana_position = ana.global_position

	# --- Animación de Fade In ---
	var tween_fade_in = create_tween()
	# Anima la propiedad 'modulate:a' (alfa) de 0 a 1 en 0.5 segundos.
	tween_fade_in.tween_property(fade_rect, "modulate:a", 1.0, 0.5) 
	# Espera a que termine el fade in.
	await tween_fade_in.finished

	# --- Espera en Negro ---
	# Ahora que está negro, espera los 2 segundos.
	await get_tree().create_timer(1.0).timeout 

	# --- Recarga la Escena ---
	load_level(_last_scene_path)
	# Dale tiempo al motor para cargar y colocar a Ana.
	await get_tree().process_frame 

	# --- Animación de Fade Out ---
	var tween_fade_out = create_tween()
	# Anima la propiedad 'modulate:a' de 1 a 0 en 0.5 segundos.
	tween_fade_out.tween_property(fade_rect, "modulate:a", 0.0, 0.5)
	# Espera a que termine el fade out.
	await tween_fade_out.finished

	# --- Limpieza ---
	transition_instance.queue_free() # Elimina la pantalla de transición.
	if hud: 
		hud.visible = true # Vuelve a mostrar el HUD.

# Función para mostrar la pantalla final del juego.
func show_end_screen() -> void:
	# Oculta el HUD y detiene el tiempo/movimiento si es necesario.
	if hud:
		hud.visible = false
	set_interaction_enabled(false)
	set_ana_movement(false)
	# Podrías detener el temporizador del día aquí también si quieres:
	# $Timer.stop() # Asumiendo que tu Timer se llama "Timer"

	# Instancia la escena de transición.
	var end_screen_instance = transition_scene.instantiate()

	# Accede al Label y establece el texto "FIN".
	var label = end_screen_instance.get_node_or_null("ColorRect/Label")
	if label:
		label.text = "FIN"
		# Opcional: Cambiar tamaño de fuente, color, etc.
		# label.add_theme_font_size_override("font_size", 64)

	# Añade la pantalla final al árbol de escenas.
	get_tree().root.add_child(end_screen_instance)

	# Opcional: Podrías añadir un temporizador para volver al menú principal después de unos segundos.
	# var return_timer = get_tree().create_timer(5.0)
	# await return_timer.timeout
	# get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn") # Ajusta la ruta a tu menú
