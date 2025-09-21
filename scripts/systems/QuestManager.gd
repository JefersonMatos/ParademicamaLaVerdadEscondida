extends Node

signal objective_changed(id: String, text: String, index: int, total: int)
signal objective_completed(id: String)
signal all_objectives_done()
signal objective_added(id: String, index: int)  # ← NUEVO (por si quieres escuchar altas en tiempo real)

var _sequence: Array[Dictionary] = []
var _idx: int = -1

func set_sequence(seq: Array) -> void:
	# Espera elementos { id: String, text: String }
	_sequence = []
	for e in seq:
		var id := str(e.get("id", ""))
		var text := str(e.get("text", ""))
		if id != "" and text != "":
			_sequence.append({"id": id, "text": text, "done": false})
	_idx = -1

func start() -> void:
	if _sequence.is_empty():
		return
	_idx = 0
	_emit_change()

func current_id() -> String:
	return _sequence[_idx]["id"] if _idx >= 0 else ""

func current_text() -> String:
	return _sequence[_idx]["text"] if _idx >= 0 else ""

func is_current(id: String) -> bool:
	return _idx >= 0 and _sequence[_idx]["id"] == id

func complete(id: String) -> void:
	var i := _find_index_by_id(id)
	if i == -1:
		return
	_sequence[i]["done"] = true
	emit_signal("objective_completed", id)
	if i == _idx:
		_advance_to_next()

func skip_to(id: String) -> void:
	var i := _find_index_by_id(id)
	if i == -1:
		return
	_idx = i
	_emit_change()

# --------- NUEVO: añadir objetivos "on the fly" ---------

func add_objective(id: String, text: String) -> void:
	# Evita duplicados; si existe, actualiza el texto
	var i := _find_index_by_id(id)
	if i != -1:
		_sequence[i]["text"] = text
		# Si justo es el activo, re-emite el cambio para refrescar HUD
		if i == _idx:
			_emit_change()
		return

	_sequence.append({"id": id, "text": text, "done": false})
	emit_signal("objective_added", id, _sequence.size() - 1)

	# Si no hay objetivo activo, arranca en este
	if _idx == -1:
		_idx = _sequence.size() - 1
		_emit_change()

func add_next(id: String, text: String) -> void:
	# Inserta justo después del actual (o al final si no hubo start())
	var entry := {"id": id, "text": text, "done": false}
	var insert_at := (_idx + 1) if _idx >= 0 else _sequence.size()
	_sequence.insert(insert_at, entry)
	emit_signal("objective_added", id, insert_at)

# --------------------------------------------------------

func _advance_to_next() -> void:
	var next := _next_unfinished_from(_idx + 1)
	if next == -1:
		# por si hay anteriores sin completar
		next = _next_unfinished_from(0)
	_idx = next
	if _idx == -1:
		emit_signal("all_objectives_done")
	else:
		_emit_change()

func _next_unfinished_from(from_index: int) -> int:
	for j in range(from_index, _sequence.size()):
		if not _sequence[j]["done"]:
			return j
	return -1

func _find_index_by_id(id: String) -> int:
	for j in range(_sequence.size()):
		if _sequence[j]["id"] == id:
			return j
	return -1

func _emit_change() -> void:
	var d := _sequence[_idx]
	emit_signal("objective_changed", d["id"], d["text"], _idx, _sequence.size())

func has_active_objective() -> bool:
	return _idx >= 0
