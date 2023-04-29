extends Node2D

var target = {}

onready var progress = $CanvasLayer/ProgressBar

func _ready():
	Transition.openScene()
	for receiver in $Receivers.get_children():
		target[receiver.deliverable] = true
		receiver.connect("received", self, "delivered")

func delivered(deliverable):
	print("DELIVERED: ", deliverable)
	if target.has(deliverable):
		target.erase(deliverable)
		
	if target.empty():
		$Drone.teleportOut()
		print("DONE")
		$NextLevelSwitcher.start()

func drone_energy(energy):
	progress.value = energy

func lost():
	print("GAME OVER")

func _on_NextLevelSwitcher_timeout():
	LevelSwitcher.next_level()
