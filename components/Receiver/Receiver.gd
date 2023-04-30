extends Node2D

#signal received(deliverable_code)

export var deliverable = "1"
export var color = Color("red")
var satisfied = false

func _ready():
	$Light2D.color = color

func satisfied():
	$Arrow.hide()
	# emit_signal("received", deliverable)
	get_node("/root/Game").delivered(deliverable)
	satisfied = true
	$Delivered.play()
	$AnimationPlayer.play("Delivered")

func _on_Area2D_body_entered(body):
	if body.is_in_group("Deliverable") and body.deliverable_type == deliverable:
		satisfied()
		body.vaporize()

func destroy():
	get_node("/root/Game").receiver_destroyed()
	queue_free()
