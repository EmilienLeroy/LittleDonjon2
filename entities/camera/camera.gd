extends QodotEntity

var alreay_used = false;

func use():
	if (properties.has('once') and properties.get('once') == 1 and alreay_used):
		return;
	
	$Camera.set_priority(30);
	
	if properties.has('delay'):
		await get_tree().create_timer(properties.get('delay')).timeout;

	alreay_used = true;
	$Camera.set_priority(0);
