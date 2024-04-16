extends Node3D

@export var animation_tree: AnimationTree;

func get_transition_state(transition: String):
	return animation_tree.get('parameters/'+ transition +'/current_state');

func get_animation_state(animation: String):
	return animation_tree.get('parameters/' +animation+ '/active');

func fire_animation(animation: String):
	animation_tree.set('parameters/'+ animation +'/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);

func abort_animation(animation: String):
	animation_tree.set('parameters/'+ animation +'/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT);
	
func fade_out_animation(animation: String):
	animation_tree.set('parameters/'+ animation +'/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT);

func seek_animation(animation: String, value: float):
	animation_tree.set('parameters/'+ animation +'/seek_request', value);

func transition_animation(animation: String, state: String):
	animation_tree.set('parameters/'+ animation +'/transition_request', state);

func set_animation_time(animation: String, time: float):
	animation_tree.set('parameters/'+ animation +'/time', time);

func get_animation_time(animation: String):
	return animation_tree.get('parameters/'+ animation +'/time');
