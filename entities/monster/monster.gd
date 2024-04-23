extends CharacterBody3D

@onready var leftLight = $Model/Armature/Skeleton3D/BoneAttachment3D/LeftLight;
@onready var rightLight = $Model/Armature/Skeleton3D/BoneAttachment3D/RightLight;

const SPEED = 2.5;
const DAMAGE = 10;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var target: Node3D = null;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_attack = false;


func _ready():
	$Detection.connect('body_entered', on_body_entered_detection);
	$Detection.connect('body_exited', on_body_exited_detection);
	$Attack.connect('body_entered', on_body_entered_attack);
	$Attack.connect('body_exited', on_body_exited_attack);
	$AttackInterval.connect('timeout', on_timeout_attack);

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if (target):
		var direction = global_position.direction_to(target.global_position);
		var look = global_transform.looking_at(target.global_position, Vector3(0, 1, 0), true);
		
		# Start the walk animation
		if (is_attack):
			$AnimationHelper.transition_animation('Locomotion', 'idle');
			return;


		$AnimationHelper.transition_animation('Locomotion', 'walk');
		
		# Increase eyes light
		leftLight.light_energy = lerp(leftLight.light_energy, 2.0, 0.05);
		rightLight.light_energy = lerp(rightLight.light_energy, 2.0, 0.05);

		# Look at the target
		global_transform = global_transform.interpolate_with(look, 0.15);
		rotation.x = 0
		
		# Set velocity to move to the target
		velocity.x = direction.x * SPEED;
		velocity.z = direction.z * SPEED;
	else:
		$AnimationHelper.transition_animation('Locomotion', 'idle');
		
		leftLight.light_energy = lerp(rightLight.light_energy, 0.3, 0.05);
		rightLight.light_energy = lerp(rightLight.light_energy, 0.3, 0.05);
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if (is_attack):
		return;

	move_and_slide();

func attack(body: Node3D):
	if (is_attack):
		return;
	
	$AnimationHelper.fire_animation('TriggerAttack');
	await get_tree().create_timer(0.3).timeout;
	
	is_attack = true;
	body.take_damage(DAMAGE, global_position);
	await get_tree().create_timer(1).timeout;
	is_attack = false;

func on_timeout_attack():
	if (!target):
		return;

	attack(target)

func on_body_entered_detection(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	target = body;

func on_body_exited_detection(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	target = null;

func on_body_entered_attack(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	attack(body);
	$AttackInterval.start();

func on_body_exited_attack(body: Node3D):
	if (!body.is_in_group('player')):
		return;
		
	$AttackInterval.stop();
