extends SpringArm3D

@export var mouse_sensibility: float = 0.005
@export var follow_speed: float = 8.0
@export var offset: Vector3 = Vector3(0, 1.5, 0)

@export var min_zoom: float = 6.0
@export var max_zoom: float = 18.0
@export var height_offset: float = 2.0
@export var vertical_min_limit: float = 1.0

@export var fov_base: float = 70.0
@export var fov_zoom_factor: float = 1.5

@export var player: Node3D

var ball: Node3D
var ball_mode := false
var mouse_captured := true

var quat: Quaternion
var pitch: float = 0.0
var yaw: float = 0.0

var smoothed_midpoint: Vector3

@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Auto find ball from group
	ball = get_tree().get_first_node_in_group("Ball")
	if !ball:
		print("No ball found in group 'ball'")

func _unhandled_input(event: InputEvent) -> void:
	# Toggle mouse
	if event.is_action_pressed("mouse_mode_change"):
		mouse_captured = !mouse_captured
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE
		)
	
	# Toggle ball cam
	if event.is_action_pressed("ball_cam"):
		ball_mode = !ball_mode
	
	# Free look (only in normal mode)
	if mouse_captured and !ball_mode and event is InputEventMouseMotion:
		var relative = event.relative * mouse_sensibility
		
		pitch -= relative.y
		yaw -= relative.x
		
		pitch = clampf(pitch, -1.3, 1.3)
		
		quat = Quaternion.from_euler(Vector3(pitch, yaw, 0))

func _physics_process(delta: float) -> void:
	if !player:
		return
	
	if ball_mode and ball:
		ball_camera_mode(delta)
	else:
		normal_camera_mode(delta)

func normal_camera_mode(delta):
	position = position.lerp(player.position + offset, follow_speed * delta)
	
	var newquat = quaternion.slerp(quat, 10 * delta)
	basis = Basis(newquat.normalized())
	
	cam.fov = lerp(cam.fov, fov_base, delta * 5)

func ball_camera_mode(delta):
	var car_pos = player.global_position
	var ball_pos = ball.global_position
	
	# 1️. Direction from car to ball
	var dir = ball_pos - car_pos
	
	# 2️. Remove vertical influence (lock Y movement)
	dir.y = 40.0
	if dir.length() < 0.01:
		return
	
	dir = dir.normalized()
	
	# 3️. Camera should be opposite side of ball
	var opposite_dir = -dir
	
	# 4️. Keep same spring length
	var fixed_distance = spring_length
	
	var target_position = car_pos + opposite_dir * fixed_distance
	
	# 5. Lock Y height (very important)
	target_position.y = global_position.y
	
	# 6️. Smooth horizontal movement only
	global_position.x = lerp(global_position.x, target_position.x, delta * follow_speed)
	global_position.z = lerp(global_position.z, target_position.z, delta * follow_speed)
	
	# 7️. Look at ball but ignore vertical tilt
	var look_target = ball_pos
	look_target.y = global_position.y
	
	look_at(look_target, Vector3.UP)
