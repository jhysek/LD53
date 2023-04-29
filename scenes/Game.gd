extends Node2D

var target = {}

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
		print("DONE")
		LevelSwitcher.next_level()
