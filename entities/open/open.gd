class_name OpenEntity
extends Area3D

signal trigger()

func _ready():
	connect('body_entered', on_body_entered);
	connect('body_exited', on_body_exited);


func open():
	trigger.emit();

func on_body_entered(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	body.open_target = self;

func on_body_exited(body: Node3D):
	if (!body.is_in_group('player')):
		return;
		
	body.open_target = null;
