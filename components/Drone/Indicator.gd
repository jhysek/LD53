extends Sprite


func enable():
	$Light2D.enabled = true
	modulate = Color("#73ff0d")
	
func disable():
	$Light2D.enabled = false
	modulate = Color("#666666")
