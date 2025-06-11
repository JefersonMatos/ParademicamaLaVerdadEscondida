extends Control

@onready var dialogic := $Dialogic
@onready var texto := $PanelContainer/RichTextLabel  # Si usas un Label para mostrar texto
var escenas_precargadas := false

func _ready():
	# Muestra un mensaje de "Cargando..."
	texto.text = "EL ACOSO Y VIOLENCIA SEXUAL LABORAL OCURRE CUANDO UNA PERSONA EN EL LUGAR DE TRABAJO REALIZA COMENTARIOS, GESTOS, TOCAMIENTOS U OTROS ACTOS DE NATURALEZA SEXUAL QUE AFECTAN LA DIGNIDAD Y BIENESTAR DE OTRA PERSONA. ESTO CREA UN AMBIENTE INCÓMODO, INTIMIDANTE O HUMILLANTE, Y PUEDE INCLUIR DESDE BROMAS Y PROPUESTAS INAPROPIADAS HASTA AGRESIONES FÍSICAS."
	# Inicia la precarga en segundo plano
	precargar_escenas_async()

func precargar_escenas_async():
	var game_state = get_tree().root.get_node("GameState")
	# Comienza la precarga de escenas
	for path in game_state.scenes.keys():
		await get_tree().create_timer(0.05).timeout
		game_state.scenes[path] = load(path)

	# Después de la precarga, marcar como terminado
	escenas_precargadas = true
	# Cuando todo esté precargado, inicia la siguiente escena (IntroScreen)
	if escenas_precargadas:
		_iniciar_intro()

func _iniciar_intro():
	# Cambia a la escena de IntroScreen
	get_tree().change_scene_to_file("res://scenes/ui/IntroScreen.tscn")
