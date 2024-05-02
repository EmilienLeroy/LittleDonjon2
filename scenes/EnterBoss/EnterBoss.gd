extends Node3D

var boss = load("res://scenes/Boss.tscn");

func _ready():
	$AnimationPlayer.play('cinematic');
	$AudioAnimation.play('cinematic')
	$AudioStreamPlayer.play(21)
	await $AnimationPlayer.animation_finished;
	Transition.transition_to(boss);
