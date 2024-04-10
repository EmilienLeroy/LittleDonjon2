extends CharacterBody3D


const SPEED = 5.0;
const DASH_SPEED = 10;
const DEFAULT_ROTATION = -180;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var current_direction: Vector3 = Vector3.ZERO;
var attack_combo = 0;

func _ready():
	$AnimationTree.connect('animation_finished', on_animation_finished);

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
	if ($AnimationTree.get('parameters/Trigger Attack/active') or $AnimationTree.get('parameters/Trigger Attack Reverse/active')):
		return;

	if (attack_combo == 0):
		$AnimationTree.set('parameters/AttackTimeSeek/seek_request', 0.6);
		$AnimationTree.set('parameters/Trigger Attack/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
		
	if (attack_combo == 1):
		$AnimationTree.set('parameters/AttackReverseTimeSeek/seek_request', 0.5);
		$AnimationTree.set('parameters/Trigger Attack Reverse/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
	
	attack_combo =+ 1;

func block():
	pass;
	
func dash():
	move_to(current_direction, SPEED * DASH_SPEED);
	move_and_slide();
	
	$AnimationTree.set('parameters/DashTimeSeek/seek_request', 0.25);
	$AnimationTree.set('parameters/Trigger Dash/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
	
func on_animation_finished(animation: StringName):
	if (animation != 'Attack' and animation != 'AttackReverse'):
		return;

	await get_tree().create_timer(1).timeout;
	
	if (!$AnimationTree.get('parameters/Trigger Attack Reverse/active') or !$AnimationTree.get('parameters/Trigger Attack/active')):
		attack_combo = 0;

