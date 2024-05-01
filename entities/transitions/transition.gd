extends CanvasLayer

func transition_to(scene: PackedScene):
	$Fade.fade_in();
	await $Fade/AnimationPlayer.animation_finished;
	get_tree().change_scene_to_packed(scene);
	$Fade.fade_out();

