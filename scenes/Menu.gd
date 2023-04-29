extends Node2D

func _ready():
	Transition.openScene()

func _on_Start_pressed():
	LevelSwitcher.start_level()
	#Transition.switchTo("res://scenes/Game.tscn")

