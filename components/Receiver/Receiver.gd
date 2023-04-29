extends Node2D

signal received(deliverable_code)

export var deliverable = "1"
var satisfied = false

func satisfied():
	emit_signal("received", deliverable)
	satisfied = true
	$Light2D.enabled = false
	$AnimationPlayer.stop()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Deliverable") and body.deliverable_type == deliverable:
		satisfied()
		body.queue_free()
