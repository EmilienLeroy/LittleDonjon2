class_name PlayerEntity
extends CharacterBody3D

signal start_open_chest
signal end_open_chest
 
@onready var helper = $AnimationHelper;
@onready var key_model = $Model/Armature/Skeleton3D/BoneAttachment3D/Key;
@onready var sword_model = $Model/Armature/Skeleton3D/BoneAttachment3D/Sword;
@onready var sword_trail = $Model/Armature/Skeleton3D/BoneAttachment3D/Sword/Trail;

const SPEED = 5.0;
const DASH_SPEED = 10;
const DEFAULT_ROTATION = -180;

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var current_direction: Vector3 = Vector3.ZERO;
var attack_combo = 0;
var open_target: OpenEntity;
var chest_target: ChestEntity;
var keys: Array[String] = [];
var is_opening_chest = false;
var disable_control = false;

func _ready():
	$AnimationKey.play('turn');
	$AttackTimer.connect('timeout', on_combo_timeout);

func _unhandled_key_input(event):
	if disable_control:
		return;
	
	if event.is_action_pressed('attack'):
		attack();
		
	if event.is_action_pressed('block'):
		block();
		
	if event.is_action_pressed('dash'):
		dash();
		
	if event.is_action_pressed('action'):
		try_resume_chest();
		try_open_door();
		try_open_chest();

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta;

	if (is_opening_chest):
		$Model.rotation.y = lerp_angle($Model.rotation.y, get_model_rotation(Vector3(0, 0, 1)), 0.3);
		return;

	var walk_speed = SPEED;
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if attack_combo == 0 and helper.get_animation_state('TriggerAttackFinal'):
		if (helper.get_animation_time('AttackFinal') > 0.5 and helper.get_animation_time('AttackFinal') < 0.9):
			walk_speed = SPEED / 1.7;
			
		if (helper.get_animation_time('AttackFinal') > 0.9 and helper.get_animation_time('AttackFinal') < 1.2):
			walk_speed = SPEED * 1.5;
	
	if direction and !disable_control:
		$Model.rotation.y = lerp_angle($Model.rotation.y, get_model_rotation(direction), 0.3);
		helper.transition_animation('Locomotion', 'walk');
		move_to(direction, walk_speed);
	else:
		helper.transition_animation('Locomotion', 'idle');
		velocity.x = move_toward(velocity.x, 0, SPEED);
		velocity.z = move_toward(velocity.z, 0, SPEED);

	current_direction = direction;	
	move_and_slide();
	update_trail();

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

	helper.fade_out_animation('TriggerAttackFinal');

	if (attack_combo == 0):
		$AttackTimer.start(0);
		helper.seek_animation('AttackTimeSeek', 0);
		helper.fire_animation('TriggerAttack');
		attack_combo = attack_combo + 1;
		
		await get_tree().create_timer(0.15).timeout;
		$AttackAudio.play();
		make_damage(10);
		
		return;

	if (attack_combo == 1):
		helper.seek_animation('AttackReverseTimeSeek', 0.5);
		helper.fire_animation('TriggerAttackReverse');
		attack_combo = attack_combo + 1;
		
		await get_tree().create_timer(0.15).timeout;
		$AttackReverseAudio.play();
		make_damage(10);
		
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
		await get_tree().create_timer(0.4).timeout;
		make_damage(20);
		
		return;

func make_damage(damage: int):
	var hitboxies = $Model/AttackZone.get_overlapping_areas();
	
	for hitbox in hitboxies:
		if (hitbox.is_in_group('monster')):
			hitbox.get_parent().take_damage(damage, global_position);

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
	
	if (open_target.is_open):
		update_info('');

func try_open_chest():
	if (!chest_target):
		return;
	
	var key = chest_target.open();

	if (!key):
		return;
	
	keys.push_back(key);
	start_open_chest.emit();
	get_tree().paused = true;
	
	await get_tree().create_timer(0.5).timeout;
	
	is_opening_chest = true;
	sword_model.visible = false;
	key_model.visible = true;
	
	helper.transition_animation('Locomotion', 'chest');
	update_info('You found a key. Press space to continue.');


func try_resume_chest():
	var is_playing_anim = helper.get_transition_state('Locomotion') == 'chest' and helper.get_animation_time('Chest') < 1
	
	if (!is_opening_chest or is_playing_anim):
		return;
		
	sword_model.visible = true;
	key_model.visible = false;
	end_open_chest.emit();
	is_opening_chest = false;
	get_tree().paused = false;
	update_info('');

func update_trail():
	if (is_attacking()):
		if (sword_trail.length != 5):
			sword_trail.length = 5;
	else:
		sword_trail.length = 1;

func on_combo_timeout():
	attack_combo = 0;

func is_attacking():
	return ((helper.get_animation_state('TriggerAttack') and helper.get_animation_time('Attack') < 0.8) 
		or (helper.get_animation_state('TriggerAttackReverse') and helper.get_animation_time('AttackReverse') < 1.2)
		or (helper.get_animation_state('TriggerAttackFinal') and helper.get_animation_time('AttackFinal') < 1.2));

func update_info(info: String):
	$CanvasLayer/Info.text = info;
