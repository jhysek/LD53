extends KinematicBody2D

#signal exploded(at_position)

var GRAVITY = 50000

var motion = Vector2(0,0)
var external_force = Vector2(0,0)
var snapped = false
var armed = false
var exploded = false

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
	$Timer.start()
	
func _physics_process(delta):
	if exploded: 
		return
		
	if !snapped:
		motion = Vector2(0, GRAVITY * delta)
		motion += external_force * delta
		motion = move_and_slide(motion)
	else:
		print('snapped...')

func explode():
	if !exploded:
		get_node("/root/Game").explosion_at(global_position)
		#emit_signal("exploded", global_position)
		$Sfx/explosion.play()
		exploded = true
		var cam = get_node("/root/Game/Drone/Camera2D")
		cam.shake(0.3, 50, 100, true)
		$Timer.start()
		$AnimationPlayer.play("Explode")

func secondary_explosions():
	for explosive in $ExplosionArea.get_overlapping_bodies():
		
		if explosive.is_in_group("Explosive") and \
			explosive != self and \
			!explosive.exploded:
			explosive.explode()
				
		if explosive.is_in_group("Hittable"):
			explosive.hit(self.position)
		
func _on_Timer_timeout():
	if not exploded:
		explode()
	else:
		print("FREEEE")
		queue_free()
