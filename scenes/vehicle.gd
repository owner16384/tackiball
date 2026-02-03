extends VehicleBody3D

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("spanned vehicle")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	

	# input + physics only on owning peer
	engine_force = Input.get_action_strength("ui_up") * 1200
	steering = Input.get_action_strength("ui_right") * 0.4
