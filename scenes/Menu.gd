extends Node2D

func _ready():
	Transition.openScene()

func _on_Start_pressed():
	Transition.switchTo("res://scenes/Game.tscn")

