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
export var presentation = false
var target_pitch = 1

func _ready():
	$AnimationPlayer.play_backwards("TeleportOut")
	if !presentation:
		set_physics_process(true)

func _physics_process(delta):
	if presentation or (game and game.paused):
		return
		
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
			#$Sfx/Fly.pitch_scale = lerp($Sfx/Fly.pitch_scale, target_pitch, 0.3)

	if energy > 0:
		consume_energy(delta)
		
	move_and_collide(motion)

func consume_energy(delta):
	if !active or (game and game.paused):
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
	
	if game:
		game.drone_energy(energy)
	
	if energy <= 0:
		release_snap()
		$AnimationPlayer.play_backwards("TakeOff")
		$Timer.start()

func hit(from):
	operational = false
	shield_enabled = true
	$AnimationPlayer.play("Shield")
	$Camera2D.shake(0.1, 50, 20)
	#var push = position - from
	#print("PUSH: " + str(push))
	#motion += push

func activate():
	if energy > 0:
		active = true
		if !presentation:
			$Sfx/TurnOn.play()
			$Sfx/Fly.play()
			target_pitch = 0.8
			$Sfx/Fly.pitch_scale = 0.8
		$AnimationPlayer.play("TakeOff")
	
func deactivate():
	active = false
	$AnimationPlayer.play_backwards("TakeOff")

func drone_control(delta):
	var pitch = 0.8
	
	if Input.is_action_pressed("ui_up"):
		if !active:
			activate()
		pitch = 1.1
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
		if !$Sfx/Magnet.playing:
			$Sfx/Magnet.play()
		pitch = 1.1
		for body in $MagneticField.get_overlapping_bodies():
			if body.is_in_group("Magnetic"):
				var dist = position.distance_to(body.position)
				if !body.snapped and dist < 85:
					$Sfx/Clamp.play()
					body.snap($Visual)
					snapped.append(body)
					$Visual/Body/Legs.hide()
					$Visual/Body/LegsSnap.show()
					magnet_flag = false
				else:
					body.external_force = - position.direction_to(body.position) * MAGNETIC_FORCE * 300 / position.distance_to(body.position)
	else:
		magnet.disable()
		$Sfx/Magnet.stop()
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
		pitch = 1.1
		left_thrust = lerp(left_thrust, THRUST, 0.2)
	else:
		left_thrust = lerp(left_thrust, 0, delta * DAMPING)
		
	if Input.is_action_pressed("ui_right"):
		pitch = 1.1
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
	
	$Sfx/Fly.pitch_scale = pitch
	
func release_snap():
	$Sfx/Unclamp.play()
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
			$Sfx/Teleport.play()
			
	if anim_name == "Shield":
		print("Shield disabled")
		operational = true
		shield_enabled = false
		
	if presentation:
		$AnimationPlayer.play("Idle")
		
func teleportOut():
	$Sfx/Fly.stop()
	operational = false
	teleporting = true
	$AnimationPlayer.play_backwards("TakeOff")

func _on_Timer_timeout():
	print("Timeouted...")
	active = false
	teleportOut()
	game.lost()

func _on_MagneticField_area_entered(area):
	print("COLLIDING AREA: " + str(area))
