extends KinematicBody2D

var GRAVITY = 1500
var HEIGHT = 100
var THRUST = 34
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
var magnet_flag = true
var teleporting = false
var shield_enabled = false

var FLYING_CONSUMPTION = 1
var CARYING_CONSUMPTION = 0.1
var MAGNET_CONSUMPTION = 0.5
var SHIELD_CONSUMPTION = 10

export var energy = 100

onready var game = get_node("/root/Game")
onready var magnet = $Visual/Body/Indicator

func _ready():
	$AnimationPlayer.play_backwards("TeleportOut")
	set_physics_process(true)

func _physics_process(delta):
	if energy > 0:
		drone_control(delta)
	
	if is_on_floor():
		print("FOOOOOOR")
		deactivate()
	
	if !active:
		motion.y = GRAVITY * delta
		rotation_degrees = lerp(rotation_degrees, 0, 0.1)
	else:
		if operational and abs(motion.x) == 0 and abs(motion.y) == 0 and $AnimationPlayer.current_animation != "Idle":
			print("IDLE")
			$AnimationPlayer.play("Idle")

	if energy > 0:
		consume_energy(delta)
		
	move_and_collide(motion)

func consume_energy(delta):
	if !active:
		return
		
	var consumption = 0
	
	consumption += FLYING_CONSUMPTION * delta
	if !snapped.empty():
		consumption += CARYING_CONSUMPTION * delta
		
	if magnet.enabled:
		consumption += MAGNET_CONSUMPTION * delta

	if shield_enabled:
		consumption += SHIELD_CONSUMPTION * delta
		
	energy -= consumption
	
	game.drone_energy(energy)
	
	if energy <= 0:
		release_snap()
		$AnimationPlayer.play_backwards("TakeOff")
		$Timer.start()

func hit(from):
	operational = false
	shield_enabled = true
	$AnimationPlayer.play("Shield")
	var push = position - from
	print("PUSH: " + str(push))
	motion += push

func activate():
	if energy > 0:
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
	
	if magnet_flag and snapped.empty() and Input.is_action_pressed("ui_accept"):
		magnet.enable()
		for body in $MagneticField.get_overlapping_bodies():
			if body.is_in_group("Magnetic"):
				var dist = position.distance_to(body.position)
				print("DIST: " + str(dist))
				if !body.snapped and dist < 85:
					body.snap($Visual)
					snapped.append(body)
					$Visual/Body/Legs.hide()
					$Visual/Body/LegsSnap.show()
					magnet_flag = false
				else:
					body.external_force = - position.direction_to(body.position) * MAGNETIC_FORCE * 300 / position.distance_to(body.position)
	else:
		magnet.disable()
		for body in $MagneticField.get_overlapping_bodies():
			if body.is_in_group("Magnetic"):
				body.external_force = Vector2(0,0)
				
	if Input.is_action_just_pressed("ui_accept"):
		if !snapped.empty():
			release_snap()
		else:
			magnet_flag = true
		
		$Visual/Body/Legs.show()
		$Visual/Body/LegsSnap.hide()
		
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
	
func release_snap():
	for node in snapped:
		if is_instance_valid(node) and node.snapped:
			node.unsnap()
			node.external_force = Vector2(0,0)
	snapped = []
	$Visual/Body/Legs.show()
	$Visual/Body/LegsSnap.hide()

func _on_MagneticField_body_entered(body):
	print("+ " + str(body))
	if body.is_in_group("Magnetic"):
		print("New crate in reach")
		
func _on_MagneticField_body_exited(body):
	if body.is_in_group("Magnetic"):
		body.external_force = Vector2(0,0)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TakeOff":
		operational = true
		if teleporting:
			operational = false
			$AnimationPlayer.play("TeleportOut")
			
	if anim_name == "Shield":
		print("Shield disabled")
		operational = true
		shield_enabled = false
		
func teleportOut():
	teleporting = true
	$AnimationPlayer.play_backwards("TakeOff")

func _on_Timer_timeout():
	print("Timeouted...")
	active = false
	teleportOut()
	game.lost()

func _on_MagneticField_area_entered(area):
	print("COLLIDING AREA: " + str(area))
