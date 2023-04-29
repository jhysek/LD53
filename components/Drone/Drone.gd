extends KinematicBody2D

var GRAVITY = 1500
var HEIGHT = 100
var THRUST = 30
var ROTATION = 100
var DAMPING = 5
var MAGNETIC_FORCE = 70000

var motion = Vector2(0,0)
var left_thrust = 0
var right_thrust = 0
var up_thrust = 0
var down_thrust = 0

var uptoggle = false
var downtoggle = false
var snapped = []

var active = false
var operational = false

onready var game = get_node("/root/Game")

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	drone_control(delta)
	
	if is_on_floor():
		print("FOOOOOOR")
		deactivate()
	
	if !active:
		motion.y = GRAVITY * delta
	else:
		if operational and abs(motion.x) == 0 and abs(motion.y) == 0 and $AnimationPlayer.current_animation != "Idle":
			print("IDLE")
			$AnimationPlayer.play("Idle")

	move_and_collide(motion)

func activate():
	active = true
	$AnimationPlayer.play("TakeOff")
	
func deactivate():
	active = false
	$AnimationPlayer.play_backwards("TakeOff")

func drone_control(delta):
	if Input.is_action_pressed("ui_up"):
		if !active:
			activate()
		uptoggle = true
		down_thrust = lerp(down_thrust, THRUST, 0.4)
	else:
		var orig_down_thrust = down_thrust
		down_thrust = lerp(down_thrust, 0, delta * DAMPING * 2)
		if uptoggle:
			uptoggle = false
			if operational:
				$AnimationPlayer.play("BounceUp")
	
	if !active:
		return
	
	if active and Input.is_action_pressed("ui_accept"):
		$Visual/Body/Indicator.enable()
		for body in $MagneticField.get_overlapping_bodies():
			if body.is_in_group("Magnetic"):
				var dist = position.distance_to(body.position)
				if !body.snapped and dist < 55:
					body.snap($Visual)
					snapped.append(body)
				else:
					body.external_force = - position.direction_to(body.position) * MAGNETIC_FORCE * 300 / position.distance_to(body.position)
				
	else:
		$Visual/Body/Indicator.disable()
		for body in $MagneticField.get_overlapping_bodies():
			if body.is_in_group("Magnetic"):
				body.external_force = Vector2(0,0)
		for node in snapped:
			if is_instance_valid(node) and node.snapped:
				node.unsnap()
				node.external_force = Vector2(0,0)
		
	if Input.is_action_pressed("ui_down"):
		downtoggle = true
		up_thrust = lerp(up_thrust, THRUST, 0.4)
	else:
		up_thrust = lerp(up_thrust, 0, 0.4)
		if downtoggle:
			downtoggle = false
			if operational:
				$AnimationPlayer.play("BounceDown")
	
	if Input.is_action_pressed("ui_left"):
		left_thrust = lerp(left_thrust, THRUST, 0.2)
	else:
		left_thrust = lerp(left_thrust, 0, delta * DAMPING)
		
	if Input.is_action_pressed("ui_right"):
		right_thrust = lerp(right_thrust, THRUST, 0.2)
	else:
		right_thrust = lerp(right_thrust, 0, delta * DAMPING)
		
	var vertical_thrust_dumping = max(0.5, (THRUST - abs(up_thrust - down_thrust)) / THRUST)
	
	rotation_degrees = (right_thrust - left_thrust) * delta * ROTATION * vertical_thrust_dumping
	
	if right_thrust == 0 && left_thrust == 0:
		rotation_degrees = lerp(rotation_degrees, 0, 0.1)
	
	var thrust = left_thrust + right_thrust
	motion.x = (right_thrust - left_thrust) * delta * THRUST
	motion.y = (up_thrust - down_thrust) * delta * THRUST
	


func _on_MagneticField_body_entered(body):
	if body.is_in_group("Magnetic"):
		print("New crate in reach")
		
	
func _on_MagneticField_body_exited(body):
	if body.is_in_group("Magnetic"):
		body.external_force = Vector2(0,0)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TakeOff":
		operational = true
