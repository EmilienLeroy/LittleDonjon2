extends Node3D

var donjon = load("res://scenes/Donjon.tscn");

func _ready():
	$CanvasLayer/Start.connect('pressed', on_start_pressed);

func on_start_pressed():
	Transition.transition_to(donjon);
