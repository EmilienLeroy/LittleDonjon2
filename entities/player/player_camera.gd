extends Node3D


func _ready():
	$Player.connect('start_open_chest', on_start_open_chest);
	$Player.connect('end_open_chest', on_end_open_chest);


func on_start_open_chest():
	$ChestCam.set_priority(20);
	
func on_end_open_chest():
	$ChestCam.set_priority(0);
