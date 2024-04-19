extends Area3D

func _ready():
	connect('body_entered', on_body_entered);

func on_body_entered(body: Node3D):
	# TODO: Setup target door to player only
