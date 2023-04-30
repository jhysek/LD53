extends Area2D

var SPEED = 1500
var fired = false
var exploded = false
var target = Vector2(0,0)
var direction = Vector2(0,0)
var time = 0

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if fired and ! exploded:
		time += delta
		position += direction * delta * SPEED
		if time > 0.2 and time < 0.4:
			direction = lerp(direction, position.direction_to(target), 0.2)

func fire(to, desired_target):
	$FreeTimer.start()
	direction = to
	target = desired_target
	fired = true

func explode():
	if !exploded:
		$Sfx/Explode.play()
		exploded = true
		$AnimationPlayer.play("Explode")
		
func _on_Bullet_body_entered(body):
	if body.is_in_group("Hittable"):
		body.hit(self.position)
		explode()

func _on_FreeTimer_timeout():
	explode()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Explode":
		queue_free()


func _on_Bullet_area_entered(area):
	if area.is_in_group("Hittable"):
		area.hit(self.position)
		explode()
