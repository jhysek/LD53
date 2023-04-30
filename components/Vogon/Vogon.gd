extends Node2D

var Bullet = load("res://components/Bullet/Bullet.tscn")
var shooting = false
var target = null

func _ready():
	pass # Replace with function body.

func vaporize():
	$AnimationPlayer.play("Vaporize")

func _on_GestureAnimation_animation_finished(anim_name):
	if anim_name == "Fire":
		$GestureAnimation.play("YellingAtCloud")
		
	if anim_name == "YellingAtCloud":
		shooting = false

func fire():
	print("Bang!")
	var bullet = Bullet.instance()
	get_node("/root/Game").add_child(bullet)
	bullet.position = $Visual/Body/ArmBack/Arm2/Gun/BulletInit.global_position
	bullet.fire(Vector2(1, -1), target.position)
	$Sfx/Fire.play()


func _on_Area2D_body_entered(body):
	if !shooting and body.is_in_group("Hittable"):
		target = body
		shooting = true
		$GestureAnimation.play("Fire")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Vaporize":
		queue_free()
