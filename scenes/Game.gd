extends Node2D

var target = {}

onready var progress = $CanvasLayer/ProgressBar

func _ready():
	#Transition.openScene()
	Transition.get_node("AnimationPlayer").play_backwards("Fade")
	for receiver in $Receivers.get_children():
		target[receiver.deliverable] = true
		
func explosion_at(pos):
	var tilemap = $TileMap
	for cell in tilemap.get_used_cells():
		var cell_pos = tilemap.map_to_world(cell)
		var dist = cell_pos.distance_to(pos)
		if dist <= 400:
			tilemap.set_cellv(cell, -1)
		if dist > 400 and dist < 500:
			tilemap.set_cellv(cell, 0)

func delivered(deliverable):
	if target.has(deliverable):
		target.erase(deliverable)
		
	print("TARGET: " + str(target))
		
	if target.empty():
		$Drone.teleportOut()
		$NextLevelSwitcher.start()

func drone_energy(energy):
	progress.value = energy

func lost():
	print("GAME OVER")

func _on_NextLevelSwitcher_timeout():
	LevelSwitcher.next_level()
