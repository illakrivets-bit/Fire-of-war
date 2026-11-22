extends Node2D

const UKRAINE_DATA := "res://assets/maps/ukraine_adm1.geojson"
const RUSSIA_DATA := "res://assets/maps/russia_adm1.geojson"
const MAP_SCALE := 100.0
const MAX_MERCATOR_LAT := 85.05112878
const MIN_ZOOM := 0.012
const MAX_ZOOM := 1.25

const UKRAINE_FILL := Color("#202830")
const RUSSIA_FILL := Color("#171e25")
const REGION_LINE := Color("#687786")
const LABEL_COLOR := Color("#c4cdd5")

@onready var camera: Camera2D = $Camera2D
@onready var status_label: Label = $CanvasLayer/Control/StatusLabel
@onready var reset_button: Button = $CanvasLayer/Control/ResetButton

var _regions: Array[Dictionary] = []
var _map_bounds := Rect2()
var _has_bounds := false
var _loaded_region_count := 0
var _touch_positions: Dictionary = {}
var _last_pinch_distance := 0.0
var _mouse_dragging := false
var _initial_camera_position := Vector2.ZERO
var _initial_zoom := Vector2.ONE


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	reset_button.pressed.connect(_reset_view)
	_load_country(UKRAINE_DATA, "Ukraine", UKRAINE_FILL)
	_load_country(RUSSIA_DATA, "Russia", RUSSIA_FILL)

	if _has_bounds:
		_initial_camera_position = _map_bounds.get_center()
		camera.position = _initial_camera_position
		_fit_map_to_viewport()
		_initial_zoom = camera.zoom
		status_label.text = "FIRE OF WAR  /  %d ADMINISTRATIVE REGIONS" % _loaded_region_count
	else:
		status_label.text = "MAP DATA MISSING  /  ADD THE TWO GEOJSON FILES"
	queue_redraw()


func _load_country(path: String, country_name: String, fill_color: Color) -> void:
	if not FileAccess.file_exists(path):
		push_warning("Missing map data: " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Could not open map data: " + path)
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not parsed.has("features"):
		push_warning("Invalid GeoJSON FeatureCollection: " + path)
		return

	for feature in parsed["features"]:
		if not feature is Dictionary:
			continue
		var geometry: Dictionary = feature.get("geometry", {})
		if geometry.is_empty():
			continue
		var properties: Dictionary = feature.get("properties", {})
		var region_name := str(properties.get("shapeName", properties.get("name", country_name)))
		var geometry_type := str(geometry.get("type", ""))
		var coordinates: Array = geometry.get("coordinates", [])

		if geometry_type == "Polygon":
			_add_polygon(coordinates, country_name, region_name, fill_color)
		elif geometry_type == "MultiPolygon":
			for polygon in coordinates:
				_add_polygon(polygon, country_name, region_name, fill_color)


func _add_polygon(rings: Array, country_name: String, region_name: String, fill_color: Color) -> void:
	if rings.is_empty():
		return

	var converted_rings: Array[PackedVector2Array] = []
	for ring_data in rings:
		var ring := PackedVector2Array()
		for coordinate in ring_data:
			if coordinate.size() < 2:
				continue
			var point := _project_coordinate(float(coordinate[0]), float(coordinate[1]))
			ring.append(point)
			if not _has_bounds:
				_map_bounds = Rect2(point, Vector2.ZERO)
				_has_bounds = true
			else:
				_map_bounds = _map_bounds.expand(point)
		if ring.size() >= 3:
			converted_rings.append(ring)

	if converted_rings.is_empty():
		return

	_regions.append({
		"country": country_name,
		"name": region_name,
		"fill": fill_color,
		"rings": converted_rings
	})
	_loaded_region_count += 1


func _project_coordinate(longitude: float, latitude: float) -> Vector2:
	var lat := clampf(latitude, -MAX_MERCATOR_LAT, MAX_MERCATOR_LAT)
	var lat_radians := deg_to_rad(lat)
	var mercator_y := log(tan(PI * 0.25 + lat_radians * 0.5))
	return Vector2(longitude * MAP_SCALE, -mercator_y * MAP_SCALE)


func _draw() -> void:
	for region in _regions:
		var rings: Array = region["rings"]
		var outer: PackedVector2Array = rings[0]
		draw_colored_polygon(outer, region["fill"])

		for ring in rings:
			var closed_ring := ring.duplicate()
			closed_ring.append(ring[0])
			draw_polyline(closed_ring, REGION_LINE, 1.35 / camera.zoom.x, true)

		if camera.zoom.x >= 0.18:
			var label_position := _ring_average(outer)
			var font := ThemeDB.fallback_font
			if font != null:
				draw_string(font, label_position, str(region["name"]), HORIZONTAL_ALIGNMENT_CENTER, -1, int(11.0 / camera.zoom.x), LABEL_COLOR)


func _ring_average(ring: PackedVector2Array) -> Vector2:
	var total := Vector2.ZERO
	for point in ring:
		total += point
	return total / maxf(1.0, float(ring.size()))


func _fit_map_to_viewport() -> void:
	if not _has_bounds:
		return
	var viewport_size := get_viewport_rect().size
	var padded_size := viewport_size * 0.86
	var width := maxf(_map_bounds.size.x, 1.0)
	var height := maxf(_map_bounds.size.y, 1.0)
	var fit_zoom := minf(padded_size.x / width, padded_size.y / height)
	fit_zoom = clampf(fit_zoom, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = Vector2.ONE * fit_zoom


func _reset_view() -> void:
	camera.position = _initial_camera_position
	camera.zoom = _initial_zoom


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_positions[event.index] = event.position
			if _touch_positions.size() == 2:
				_last_pinch_distance = _current_pinch_distance()
		else:
			_touch_positions.erase(event.index)
			if _touch_positions.size() < 2:
				_last_pinch_distance = 0.0

	elif event is InputEventScreenDrag:
		if _touch_positions.has(event.index):
			_touch_positions[event.index] = event.position
		if _touch_positions.size() == 1:
			camera.position -= event.relative / camera.zoom.x
		elif _touch_positions.size() >= 2:
			var new_distance := _current_pinch_distance()
			if _last_pinch_distance > 0.0 and new_distance > 0.0:
				_apply_zoom(new_distance / _last_pinch_distance)
			_last_pinch_distance = new_distance

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_mouse_dragging = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(1.12)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(0.89)

	elif event is InputEventMouseMotion and _mouse_dragging:
		camera.position -= event.relative / camera.zoom.x


func _current_pinch_distance() -> float:
	if _touch_positions.size() < 2:
		return 0.0
	var positions: Array = _touch_positions.values()
	return positions[0].distance_to(positions[1])


func _apply_zoom(factor: float) -> void:
	var next_zoom := clampf(camera.zoom.x * factor, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = Vector2.ONE * next_zoom
