extends CharacterBody3D

const SPEED = 5.0;
const DASH_SPEED = 10;
const DEFAULT_ROTATION = -180;

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
	if not is_on_floor():
		velocity.y -= gravity * delta

	var walk_speed = SPEED;
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if attack_combo == 2 and get_animation_state('TriggerAttackFinal'):
		walk_speed = SPEED / 1.5;

	if direction:
		$Model.rotation.y = lerp_angle($Model.rotation.y, get_model_rotation(direction), 0.3);
		transition_animation('Locomotion', 'walk');
		move_to(direction, walk_speed);
	else:
		transition_animation('Locomotion', 'idle');
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
	if (
		get_animation_state('TriggerAttack') 
		or get_animation_state('TriggerAttackReverse')
		or get_animation_state('TriggerAttackFinal')
	):
		return;

	if (attack_combo == 0):
		fire_animation('TriggerAttack');

	if (attack_combo == 1):
		seek_animation('AttackReverseTimeSeek', 0.5);
		fire_animation('TriggerAttackReverse');
		
	if (attack_combo == 2):
		seek_animation('AttackFinalTimeSeek', 0.3);
		fire_animation('TriggerAttackFinal');
		

func block():
	pass;
	
func dash():
	move_to(current_direction, SPEED * DASH_SPEED);
	move_and_slide();
	seek_animation('DashTimeSeek', 0.25);
	fire_animation('TriggerDash');

func on_animation_finished(animation: StringName):
	if (animation == 'Attack' or animation == 'AttackReverse'):
		attack_combo = attack_combo + 1
		await get_tree().create_timer(0.5).timeout;
		
		if (
			!get_animation_state('TriggerAttack')
			and !get_animation_state('TriggerAttackReverse')
			and !get_animation_state('TirggerAttackFinal')
		):
			attack_combo = 0;

		return;
	
	if (animation == 'AttackSlash'):
		attack_combo = 0;
		return;

func get_animation_state(animation: String):
	return $AnimationTree.get('parameters/' +animation+ '/active');

func fire_animation(animation: String):
	$AnimationTree.set('parameters/'+ animation +'/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
	
func seek_animation(animation: String, value: float):
	$AnimationTree.set('parameters/'+ animation +'/seek_request', value);

func transition_animation(animation: String, state: String):
	$AnimationTree.set('parameters/'+ animation +'/transition_request', state);
