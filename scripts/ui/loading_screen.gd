extends Control

@onready var texto := $PanelContainer/RichTextLabel  # Si usas un Label para mostrar texto
@onready var hud = get_node("/root/GameState/HUD")  # Ruta al HUD
var escenas_precargadas := false

func _ready():
	# Muestra el mensaje de "Cargando..."
	texto.text = "EL ACOSO Y VIOLENCIA SEXUAL LABORAL OCURRE CUANDO UNA PERSONA EN EL LUGAR DE TRABAJO REALIZA COMENTARIOS, GESTOS, TOCAMIENTOS U OTROS ACTOS DE NATURALEZA SEXUAL QUE AFECTAN LA DIGNIDAD Y BIENESTAR DE OTRA PERSONA. ESTO CREA UN AMBIENTE INCÓMODO, INTIMIDANTE O HUMILLANTE, Y PUEDE INCLUIR DESDE BROMAS Y PROPUESTAS INAPROPIADAS HASTA AGRESIONES FÍSICAS."

	# Ocultar el HUD mientras está activa la pantalla de carga
	hud.visible = false
	
	# Inicia la precarga en segundo plano
	precargar_escenas_async()

func precargar_escenas_async():
	var game_state = get_tree().root.get_node("GameState")
	# Comienza la precarga de escenas
	var scenes_to_load = game_state.scenes.keys()
	
	for path in scenes_to_load:
		await get_tree().create_timer(0.1).timeout  # Pausa para la UI
		game_state.scenes[path] = load(path)
		
	escenas_precargadas = true
	if escenas_precargadas:
		_iniciar_intro()

func _iniciar_intro():
	# Cambia a la escena de IntroScreen
	get_tree().change_scene_to_file("res://scenes/ui/IntroScreen.tscn")
