extends Node3D

@export var disable_control: bool = false;

func _ready():
	$Player.disable_control = disable_control;
	$Player.connect('start_open_chest', on_start_open_chest);
	$Player.connect('end_open_chest', on_end_open_chest);


func on_start_open_chest():
	$ChestCam.set_priority(20);
	
func on_end_open_chest():
	$ChestCam.set_priority(0);
