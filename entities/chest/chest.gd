class_name ChestEntity
extends StaticBody3D

@export var properties: Dictionary;

var is_open = false;

func _ready():
	$Open.connect('body_entered', on_body_entered);
	$Open.connect('body_exited', on_body_exited);

func open():
	if (is_open):
		return;
		
	is_open = true;
	$Model/AnimationPlayer.play('open');

	return properties.get('key_name');
	

func on_body_entered(body: Node3D):
	if (!body.is_in_group('player')):
		return
	
	body.chest_target = self;

func on_body_exited(body: Node3D):
	if (!body.is_in_group('player')):
		return
		
	body.chest_target = null;
