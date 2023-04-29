extends KinematicBody2D

var GRAVITY = 20000
var motion = Vector2(0,0)
var external_force = Vector2(0,0)
var snapped = false

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	motion = Vector2(0, GRAVITY * delta)
	motion -= Vector2(0, external_force.y) * delta
	motion = move_and_slide(motion)

func snap(to):
	pass
	
func unsnap():
	pass
