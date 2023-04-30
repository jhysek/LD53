extends Control

var QuotaCrate = preload("res://components/DeliveryQuota/QuotaCrate.tscn")

onready var game = get_node("/root/Game")

var total = 0
var boxes = {}


func refresh_boxes(to_deliver):
	print("Refreshing boxes on delivery quota....")
	total = 0
	for box in $Boxes.get_children():
		box.queue_free()
		
	for type in to_deliver:
		var config = to_deliver[type]
		total += 1
		var crate = QuotaCrate.instance()
		$Boxes.add_child(crate)
		crate.scale = Vector2(0.25, 0.25)
		crate.position.x = 120 + total * 50
		crate.position.y = 12
		crate.config(config.color, config.deliverable)
		boxes[type] = crate

