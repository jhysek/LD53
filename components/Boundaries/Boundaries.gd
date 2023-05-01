extends Node2D

onready var dialog = get_node("/root/Game/CanvasLayer/ExpressDialog")
onready var game = get_node("/root/Game")

func _on_SlackingArea_body_entered(body):
	if body.is_in_group("Player"):
		game.paused = true
		dialog.showDialog("Get back to work, immediately!", false, true, false)

	if body.is_in_group("Deliverable"):
		body.vaporize()
		game.lost_package()
		
func _on_KillArea_body_exited(body):
	if body.is_in_group("Player"):
		game.paused = true
		dialog.showDialog("Ok, you wanted it. Forgot your bonuses!", true, false, false)

