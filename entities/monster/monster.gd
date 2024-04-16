extends CharacterBody3D


const SPEED = 2.5;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var target: Node3D = null;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	$Detection.connect('body_entered', on_body_entered);
	$Detection.connect('body_exited', on_body_exited);

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if (target):
		var direction = global_position.direction_to(target.global_position);
		
		look_at(target.global_position, Vector3(0, 1, 0), true);
		$AnimationHelper.transition_animation('Locomotion', 'walk');
		
		rotation.x = 0
		velocity.x = direction.x * SPEED;
		velocity.z = direction.z * SPEED;
	else:
		$AnimationHelper.transition_animation('Locomotion', 'idle');
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide();

func on_body_entered(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	target = body;

func on_body_exited(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	target = null;
