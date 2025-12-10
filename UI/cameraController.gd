extends Camera2D

@export var p1 : Node2D
@export var p2 : Node2D

var min_zoom = 0.75
var max_zoom = 1.0
var zoom_speed = 3.0
var follow_speed = 5.0

# PÁLYA határai (a teljes pálya méretei)
var level_boundary_min = Vector2(-350, -200)  # pálya bal felső sarka
var level_boundary_max = Vector2(1500, 800)   # pálya jobb alsó sarka

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not p1 or not p2:
		return
	
	# 1. KÖZÉPPONT SZÁMÍTÁS
	var p1pos = p1.global_position
	var p2pos = p2.global_position
	var targetPos = (p1pos + p2pos) * 0.5
	
	# 2. SIMA KÖVETÉS
	global_position = global_position.lerp(targetPos, delta * follow_speed)
	
	# 3. ZOOM SZÁMÍTÁS
	var distance = p1pos.distance_to(p2pos)
	var t = clamp((distance - 400.0) / 500.0, 0.0, 1.0)
	var target_zoom_value = lerp(max_zoom, min_zoom, t)
	zoom = zoom.lerp(Vector2(target_zoom_value, target_zoom_value), delta * zoom_speed)
	
	# 4. KAMERA HATÁROK
	apply_camera_boundaries()

func apply_camera_boundaries():
	var viewport_size = get_viewport_rect().size
	var margin = Vector2(viewport_size.x * zoom.x / 2, viewport_size.y * zoom.y / 2)
	
	global_position.x = clamp(global_position.x, level_boundary_min.x + margin.x*1.2, level_boundary_max.x - margin.x*1.2)
	global_position.y = clamp(global_position.y, level_boundary_min.y + margin.y*1.2, level_boundary_max.y - margin.y*1.2)
