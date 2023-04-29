extends KinematicBody2D

var GRAVITY = 50000

var motion = Vector2(0,0)
var external_force = Vector2(0,0)
var snapped = false
var armed = false

func _ready():
	set_physics_process(true)

func reparent(new_parent):
	var new_pos = position + get_parent().position
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = new_pos

func snap(to):
	snapped = true
	collision_mask = 0
	var global_pos = global_position
	reparent(to)
	$CollisionShape2D.disabled = true
	global_position = global_pos
	
func unsnap():
	snapped = false
	var global_pos = global_position
	reparent(get_node("/root/Game"))
	global_position = global_pos
	collision_mask = 0
	$CollisionShape2D.disabled = false
	armed = true
	$AnimationPlayer.play("Armed")
	
func _physics_process(delta):
	if !snapped:
		motion = Vector2(0, GRAVITY * delta)
		motion += external_force * delta
		motion = move_and_slide(motion)
	else:
		print('snapped...')
