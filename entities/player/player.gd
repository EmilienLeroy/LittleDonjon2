extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const DEFAULT_ROTATION = -180;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		$Model.rotation.y = get_model_rotation(direction);
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func get_model_rotation(direction: Vector3) -> float:
		if direction.z == 1:
			return 0;
			
		if direction.z == -1:
			return deg_to_rad(DEFAULT_ROTATION);
		
		if direction.x == 1 or direction.x == -1:
			return deg_to_rad(DEFAULT_ROTATION * -direction.x * 0.5);
			
		if direction.x > 0 and direction.z > 0:
			return deg_to_rad(-DEFAULT_ROTATION * 0.25);
		
		if direction.x < 0 and direction.z > 0:
			return deg_to_rad(DEFAULT_ROTATION * 0.25);
		
		if direction.x > 0 and direction.z < 0:
			return deg_to_rad(-DEFAULT_ROTATION * 0.75);
		
		if direction.x < 0 and direction.z < 0:
			return deg_to_rad(DEFAULT_ROTATION * 0.75);

		return 0;
