extends CharacterBody3D

const SPEED = 1.2;

var target: PlayerEntity;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Detection.connect('body_entered', on_body_detected);
	$Detection.connect('body_exited', on_body_undetected);
	$PhysicAttack.connect('body_entered', on_body_entered_physic_attack);
	pass # Replace with function body.

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if (target):
		var direction = global_position.direction_to(target.global_position);
		var look = global_transform.looking_at(target.global_position, Vector3(0, 1, 0), true);

		$AnimationHelper.transition_animation('Locomotion', 'walk');

		# Look at the target
		global_transform = global_transform.interpolate_with(look, 0.05);
		rotation.x = 0
		
		# Set velocity to move to the target
		velocity.x = direction.x * SPEED;
		velocity.z = direction.z * SPEED;
	else:
		$AnimationHelper.transition_animation('Locomotion', 'idle');
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)	
	
	move_and_slide();

func on_body_detected(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	target = body;

func on_body_undetected(body: Node3D):
	if (!body.is_in_group('player')):
		return;
		
	target = null;

func on_body_entered_physic_attack(body: Node3D):
	if (!body.is_in_group('player')):
		return;

	$AnimationHelper.fire_animation('TriggerAttack');
