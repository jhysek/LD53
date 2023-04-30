extends Sprite

var type = "1"

func config(color, deliverable_type):
	$Sprite.modulate = color
	type = deliverable_type
	
func done():
	self_modulate = Color("ffffffff")
