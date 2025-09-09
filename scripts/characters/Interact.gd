extends Area2D
signal interact(body: Node)   # quien entró (Ana)

@export var prompt_text := "[E] Hablar"
@export var action := "ui_accept"  # asegúrate que incluye la tecla E

var _inside := false
var _who: Node = null
var _gs: Node

func _ready() -> void:
	_gs = get_tree().root.get_node("GameState")
	monitoring = true
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)
	set_process_unhandled_input(true)

func _on_entered(body: Node) -> void:
	if body.name != "Ana": return
	_inside = true
	_who = body
	if !_gs.is_dialog_active:  # Asegura que solo se muestre si no hay diálogo activo
		_gs.hud_show_interact(prompt_text)

func _on_exited(body: Node) -> void:
	if body != _who: return
	_inside = false
	_who = null
	_gs.hud_hide_interact()

func _unhandled_input(event: InputEvent) -> void:
	if not _inside: return
	if event.is_action_pressed(action):
		_gs.hud_hide_interact()
		emit_signal("interact", _who)  # Emitir la señal al presionar "E"
