extends Node2D

func _ready():
	Transition.get_node("AnimationPlayer").play_backwards("Fade")
	$Drone.activate()
	Transition.openScene()

func _on_Start_pressed():
	$Start/Click.play()
	$Timer.start()

func _on_Start_mouse_entered():
	$Start/Hover.play()

func _on_Start_mouse_exited():
	$Start/Hover.play()

func _on_Timer_timeout():
	LevelSwitcher.start_level()
