extends CanvasLayer

@onready var root := $Root
@onready var objective := $Root/Objective
@onready var interact := $Root/Interact
@onready var interact_label := $Root/Interact/InteractLabel
@onready var location_label := $Root/Location
@onready var day_label := $Root/Day
@onready var progress_bar := $Root/ProgressBar

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

# ---- actualización del día y barra de progreso ----
func set_day(text: String) -> void:
	if day_label:
		day_label.text = text

func set_time_left(text: String) -> void:
	# Esto actualizará el texto del tiempo restante
	if day_label:
		day_label.text = text

func set_progress_bar(progress: float) -> void:
	# Establece el valor de la barra de progreso del tiempo
	if progress_bar:
		progress_bar.value = progress * 100  # La barra de progreso espera un valor entre 0 y 100
