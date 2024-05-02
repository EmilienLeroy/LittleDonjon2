class_name GoEntity
extends Area3D

var donjon = load("res://scenes/Donjon.tscn");
var boss = load("res://scenes/EnterBoss/EnterBoss.tscn");

var scenes = {
	'donjon': donjon,
	'boss': boss,
}

@export var properties: Dictionary;

func _ready():
	connect('body_entered', on_body_entered);

func on_body_entered(body: Node3D):
	if (!body.is_in_group('player')):
		return;
	
	var scene = scenes[properties.get('to')];
	
	Transition.transition_to(scene);
