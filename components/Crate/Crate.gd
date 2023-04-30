extends KinematicBody2D

var GRAVITY = 40000

var motion = Vector2(0,0)
var external_force = Vector2(0,0)
var snapped = false

export var deliverable_type = "1"
export var color = Color("red")

func _ready():
	$Box/Lights.modulate = color
	set_physics_process(true)

func reparent(new_parent):
	var new_pos = position + get_parent().position
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = new_pos

func vaporize():
	$AnimationPlayer.play("Vaporize")
		
func snap(to):
	snapped = true
	collision_mask = 0
	$CollisionShape2D.disabled = true
	var global_pos = global_position
	reparent(to)
	show_behind_parent = true
	global_position = global_pos
	
func unsnap():
	snapped = false
	var global_pos = global_position
	reparent(get_node("/root/Game"))
	collision_mask = 1
	global_position = global_pos
	show_behind_parent = false
	$CollisionShape2D.disabled = false
	
	
func _physics_process(delta):
	if !snapped:
		motion = Vector2(0, GRAVITY * delta)
		motion += external_force * delta
		motion = move_and_slide(motion)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Vaporize":
		queue_free()
