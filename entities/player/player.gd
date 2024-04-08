extends CharacterBody3D


const SPEED = 5.0;
const DASH_SPEED = 10;
const DEFAULT_ROTATION = -180;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var current_direction: Vector3 = Vector3.ZERO;

func _unhandled_key_input(event):
	if event.is_action_pressed('attack'):
		attack();
		
	if event.is_action_pressed('block'):
		block();
		
	if event.is_action_pressed('dash'):
		dash();

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		$Model.rotation.y = lerp_angle($Model.rotation.y, get_model_rotation(direction), 0.3);
		$AnimationTree.set('parameters/Locomotion/transition_request', 'walk');
		move_to(direction, SPEED);
	else:
		$AnimationTree.set('parameters/Locomotion/transition_request', 'idle');
		velocity.x = move_toward(velocity.x, 0, SPEED);
		velocity.z = move_toward(velocity.z, 0, SPEED);

	current_direction = direction;
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

func move_to(direction: Vector3, speed: float):
	velocity.x = direction.x * speed;
	velocity.z = direction.z * speed;

func attack():
	if ($AnimationTree.get('parameters/Trigger Attack/active')):
		return;

	$AnimationTree.set('parameters/AttackTimeSeek/seek_request', 0.6);
	$AnimationTree.set('parameters/Trigger Attack/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
	
func block():
	pass;
	
func dash():
	move_to(current_direction, SPEED * DASH_SPEED);
	move_and_slide()
