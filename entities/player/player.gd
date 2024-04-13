extends CharacterBody3D

const SPEED = 5.0;
const DASH_SPEED = 10;
const DEFAULT_ROTATION = -180;

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var current_direction: Vector3 = Vector3.ZERO;
var attack_combo = 0;

func _ready():
	$AttackTimer.connect('timeout', on_combo_timeout);

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
	
	if attack_combo == 0 and get_animation_state('TriggerAttackFinal'):
		if (get_animation_time('AttackFinal') > 0.5 and get_animation_time('AttackFinal') < 0.9):
			walk_speed = SPEED / 1.7;
			
		if (get_animation_time('AttackFinal') > 0.9 and get_animation_time('AttackFinal') < 1.2):
			walk_speed = SPEED * 1.5;
	
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
		(get_animation_state('TriggerAttack') and get_animation_time('Attack') < 0.5) 
		or (get_animation_state('TriggerAttackReverse') and get_animation_time('AttackReverse') < 1.2)
		or (get_animation_state('TriggerAttackFinal') and get_animation_time('AttackFinal') < 1.2)
	):
		return;

	fade_out_animation('TriggerAttackFinal')

	if (attack_combo == 0):
		$AttackTimer.start(0);
		seek_animation('AttackTimeSeek', 0);
		fire_animation('TriggerAttack');
		attack_combo = attack_combo + 1;
		
		await get_tree().create_timer(0.15).timeout;
		$AttackAudio.play();
		
		return;

	if (attack_combo == 1):
		seek_animation('AttackReverseTimeSeek', 0.5);
		fire_animation('TriggerAttackReverse');
		attack_combo = attack_combo + 1;
		
		await get_tree().create_timer(0.15).timeout;
		$AttackReverseAudio.play()
		
		return;
		
	if (attack_combo == 2):
		$AttackTimer.stop();
		seek_animation('AttackFinalTimeSeek', 0.3);
		fire_animation('TriggerAttackFinal');
		attack_combo = 0;
		
		await get_tree().create_timer(0.5).timeout;
		$AttackFinalAudio.play();
		
		return;
	

func block():
	pass;
	
func dash():
	move_to(current_direction, SPEED * DASH_SPEED);
	move_and_slide();
	seek_animation('DashTimeSeek', 0.25);
	fire_animation('TriggerDash');
	$DashAudio.play();
	

func on_combo_timeout():
	attack_combo = 0;

func get_animation_state(animation: String):
	return $AnimationTree.get('parameters/' +animation+ '/active');

func fire_animation(animation: String):
	$AnimationTree.set('parameters/'+ animation +'/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);

func abort_animation(animation: String):
	$AnimationTree.set('parameters/'+ animation +'/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT);
	
func fade_out_animation(animation: String):
	$AnimationTree.set('parameters/'+ animation +'/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT);

func seek_animation(animation: String, value: float):
	$AnimationTree.set('parameters/'+ animation +'/seek_request', value);

func transition_animation(animation: String, state: String):
	$AnimationTree.set('parameters/'+ animation +'/transition_request', state);

func set_animation_time(animation: String, time: float):
	$AnimationTree.set('parameters/'+ animation +'/time', time);

func get_animation_time(animation: String):
	return $AnimationTree.get('parameters/'+ animation +'/time');
