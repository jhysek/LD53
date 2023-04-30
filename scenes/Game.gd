extends Node2D

var target = {}
var paused = false

onready var progress = $CanvasLayer/ProgressBar

func _ready():
	$CanvasLayer/ProgressBar.max_value = $Drone.energy
	set_process_input(true)
	Transition.get_node("AnimationPlayer").play_backwards("Fade")
	for receiver in $Receivers.get_children():
		target[receiver.deliverable] = { 
			color = receiver.color, 
			deliverable = receiver.deliverable 
		}
	$CanvasLayer/DeliveryQuota.refresh_boxes(target)
	
	if LevelSwitcher.current_level == 0:
		paused = true
		$CanvasLayer/ExpressDialog.showDialog("You are hired! You'll work as a delivery operator. You need to absolve training first.", false, true, false)
		
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		paused = true
		$CanvasLayer/ExpressDialog.showDialog("Slacking, huh? I'm wathching you!", false, true, false)
		
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
		$CanvasLayer/DeliveryQuota.refresh_boxes(target)
	
	if target.empty():
		$Drone.teleportOut()
		$NextLevelSwitcher.start()

	

func drone_energy(energy):
	progress.value = energy

func lost():
	paused = true
	$CanvasLayer/ExpressDialog.showDialog("Quotas not met. Shape up or ship out!", true, false, false)

func _on_NextLevelSwitcher_timeout():
	paused = true
	$CanvasLayer/ExpressDialog.showDialog("You finished the job against all expectations.\n\n[Enter] for next delivery", false, false, true)

func out_of_energy():
	if !target.empty():
		lost()
		
func receiver_destroyed():
	paused = true
	$CanvasLayer/ExpressDialog.showDialog("You have destroyed client's receiving device\nPaying for it from your bonuses.", true, false, false)

