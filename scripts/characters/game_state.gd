extends Node

@onready var current_level := $CurrentLevel
@onready var ana := $Ana

# Nombre del punto de aparición por defecto
var spawn_name := "SpawnAna"

# Diccionario de rutas a niveles (inicialmente sin precarga)
var scenes := {
	"res://scenes/levels/NivelOficina.tscn": null,
	"res://scenes/levels/NivelOficinaJefe.tscn": null,
	"res://scenes/levels/NivelComedor.tscn": null,
	"res://scenes/levels/NivelSalaConserje.tscn": null,
	"res://scenes/levels/NivelSalaVigilancia.tscn": null,
	"res://scenes/levels/NivelSalaJuntas.tscn": null,
	"res://scenes/levels/NivelEstudioGrabacion.tscn": null
}

func _ready():
	# Oculta a Ana y el nivel actual hasta que se muestre el MainMenu
	if ana is CanvasItem:
		ana.visible = false
		if ana.has_node("Camera2D"):
			ana.get_node("Camera2D").enabled = false

	if current_level is CanvasItem:
		current_level.visible = false

# Método para activar la visibilidad del juego real
func activar_modo_juego():
	if ana is CanvasItem:
		ana.visible = true
		if ana.has_node("Camera2D"):
			ana.get_node("Camera2D").enabled = true

	if current_level is CanvasItem:
		current_level.visible = true

# Carga un nivel desde el diccionario o directamente
func load_level(scene_path: String):
	# Elimina el nivel actual si existe
	if current_level.get_child_count() > 0:
		current_level.get_child(0).queue_free()

	# Usa precarga si existe
	var scene_res = scenes.get(scene_path, null)
	if scene_res == null:
		scene_res = load(scene_path)

	call_deferred("_load_new_scene", scene_res)

# Instancia nueva escena y coloca a Ana en el punto de aparición
func _load_new_scene(scene_res):
	var new_scene = scene_res.instantiate()
	current_level.add_child(new_scene)

	var spawn = new_scene.get_node_or_null(spawn_name)
	if spawn and ana:
		ana.global_position = spawn.global_position
