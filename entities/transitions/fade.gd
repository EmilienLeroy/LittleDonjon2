extends CanvasLayer

func fade_in():
	$AnimationPlayer.play("in");
	
func fade_out():
	$AnimationPlayer.play("out");
