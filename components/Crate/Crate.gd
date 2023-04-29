extends KinematicBody2D

var GRAVITY = 40000

var motion = Vector2(0,0)
var external_force = Vector2(0,0)
var snapped = false

func _ready():
	set_physics_process(true)

func reparent(new_parent):
	var new_pos = position + get_parent().position
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = new_pos

func snap(to):
	snapped = true
	collision_layer = 8
	collision_mask = 8
	var global_pos = global_position
	reparent(to)
	global_position = global_pos
	
func unsnap():
	snapped = false
	reparent(get_node("/root/Game"))
	collision_layer = 1
	collision_mask = 1
	
	
func _physics_process(delta):
	if !snapped:
		motion = Vector2(0, GRAVITY * delta)
		motion += external_force * delta
		motion = move_and_slide(motion)
	else:
		print('snapped...')
