extends CharacterBody3D

signal start_open_chest
signal end_open_chest
 
@onready var helper = $AnimationHelper;

const SPEED = 5.0;
const DASH_SPEED = 10;
const DEFAULT_ROTATION = -180;

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var current_direction: Vector3 = Vector3.ZERO;
var attack_combo = 0;
var open_target: OpenEntity;
var chest_target: ChestEntity;
var keys: Array[String] = [];

func _ready():
	$AttackTimer.connect('timeout', on_combo_timeout);

func _unhandled_key_input(event):
	if event.is_action_pressed('attack'):
		attack();
		
	if event.is_action_pressed('block'):
		block();
		
	if event.is_action_pressed('dash'):
		dash();
		
	if event.is_action_pressed('action'):
		try_open_door();
		try_open_chest();

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var walk_speed = SPEED;
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if attack_combo == 0 and helper.get_animation_state('TriggerAttackFinal'):
		if (helper.get_animation_time('AttackFinal') > 0.5 and helper.get_animation_time('AttackFinal') < 0.9):
			walk_speed = SPEED / 1.7;
			
		if (helper.get_animation_time('AttackFinal') > 0.9 and helper.get_animation_time('AttackFinal') < 1.2):
			walk_speed = SPEED * 1.5;
	
	if direction:
		$Model.rotation.y = lerp_angle($Model.rotation.y, get_model_rotation(direction), 0.3);
		helper.transition_animation('Locomotion', 'walk');
		move_to(direction, walk_speed);
	else:
		helper.transition_animation('Locomotion', 'idle');
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
		(helper.get_animation_state('TriggerAttack') and helper.get_animation_time('Attack') < 0.5) 
		or (helper.get_animation_state('TriggerAttackReverse') and helper.get_animation_time('AttackReverse') < 1.2)
		or (helper.get_animation_state('TriggerAttackFinal') and helper.get_animation_time('AttackFinal') < 1.2)
	):
		return;

	helper.fade_out_animation('TriggerAttackFinal')

	if (attack_combo == 0):
		$AttackTimer.start(0);
		helper.seek_animation('AttackTimeSeek', 0);
		helper.fire_animation('TriggerAttack');
		attack_combo = attack_combo + 1;
		
		await get_tree().create_timer(0.15).timeout;
		$AttackAudio.play();
		
		return;

	if (attack_combo == 1):
		helper.seek_animation('AttackReverseTimeSeek', 0.5);
		helper.fire_animation('TriggerAttackReverse');
		attack_combo = attack_combo + 1;
		
		await get_tree().create_timer(0.15).timeout;
		$AttackReverseAudio.play()
		
		return;
		
	if (attack_combo == 2):
		attack_combo = 0;

		if (helper.get_transition_state('Locomotion') == 'idle'):
			return;

		$AttackTimer.stop();
		helper.seek_animation('AttackFinalTimeSeek', 0.3);
		helper.fire_animation('TriggerAttackFinal');
		
		await get_tree().create_timer(0.5).timeout;
		$AttackFinalAudio.play();
		
		return;
	

func block():
	pass;
	
func dash():
	if (helper.get_transition_state('Locomotion') == 'idle'):
		return;
	
	helper.seek_animation('DashTimeSeek', 0.25);
	helper.fire_animation('TriggerDash');
	move_to(current_direction, SPEED * DASH_SPEED);
	move_and_slide();
	$DashAudio.play();

func take_damage(damage: float, from: Vector3):
	var damage_direction = from.direction_to(global_position);
	
	velocity.x = damage_direction.x * SPEED * 7;
	velocity.z = damage_direction.z * SPEED * 7;
	
	helper.fire_animation('TriggerDamage');
	move_and_slide();

func try_open_door():
	if (!open_target):
		return;
		
	open_target.open(keys);

func try_open_chest():
	if (!chest_target):
		return;
	
	var key = chest_target.open();

	if (!key):
		return;
		
	keys.push_back(key);
	
	start_open_chest.emit();
	get_tree().paused = true;
	
	await get_tree().create_timer(2).timeout;
	
	end_open_chest.emit();
	get_tree().paused = false;

func on_combo_timeout():
	attack_combo = 0;
