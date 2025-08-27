extends CanvasLayer

@onready var root := $Root
@onready var objective := $Root/Objective
@onready var interact := $Root/Interact
@onready var interact_label := $Root/Interact/InteractLabel
@onready var location_label := $Root/Location   # ← ruta correcta

# ---- API pública ----
func set_objective(text: String) -> void:
	objective.text = text

func show_interact(text: String = "[E] Hablar") -> void:
	interact_label.text = text
	interact.visible = true
	interact.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(interact, "modulate:a", 1.0, 0.15)

func hide_interact() -> void:
	if not interact.visible:
		return
	var tw = create_tween()
	tw.tween_property(interact, "modulate:a", 0.0, 0.12)
	tw.tween_callback(Callable(self, "_after_hide"))

func _after_hide() -> void:
	interact.visible = false

# ---- ubicación actual ----
func set_location(text: String) -> void:
	if location_label:
		location_label.text = text
