extends Sprite

var enabled = false

func enable():
	enabled = true
	$Light2D.enabled = true
	modulate = Color("#73ff0d")
	
func disable():
	enabled = false
	$Light2D.enabled = false
	modulate = Color("#666666")
