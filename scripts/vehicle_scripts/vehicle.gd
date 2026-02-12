class_name Vehicle
extends VehicleBody3D

@onready var movement: movement = $movement



func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	movement._ready()

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	movement.current_speed = linear_velocity.length()
	movement.time_since_jump += delta
	
	movement._check_ground()
	
	if movement.is_grounded:
		movement._ground_driving(delta)
		movement._apply_stabilization(delta)
		movement._apply_downforce()
	else:
		movement._air_control(delta)
	
	movement._handle_jump()
	movement._handle_boost(delta)
	movement._handle_drift()
	movement._clamp_speed()
