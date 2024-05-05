class_name OpenEntity
extends Area3D

@export var properties: Dictionary;
var is_open = false;

signal trigger()

func _ready():
	connect('body_entered', on_body_entered);
	connect('body_exited', on_body_exited);

func open(keys: Array[String]):
	if (properties.has('key_name') && !keys.has(properties.key_name)):
		return;

	trigger.emit();
	is_open = true;

func on_body_entered(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	body.open_target = self;
	
	if (properties.has('key_name') && !body.keys.has(properties.key_name)):
		body.update_info('You need a key to open the door.');
	elif(!is_open):
		body.update_info('Press Space to open the door.');
	else:
		body.update_info('');

func on_body_exited(body: Node3D):
	if (!body.is_in_group('player')):
		return;
		
	body.open_target = null;
	body.update_info('');
