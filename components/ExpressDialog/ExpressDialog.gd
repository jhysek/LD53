extends Panel

var restart = false
var is_visible = false

func _ready():
	visible = false
	set_process_input(true)
	
func showDialog(msg, buttonRestart, buttonContinue, buttonNext):
	visible = true
	$info.text = msg
	$Reset.visible = buttonRestart
	$Reset.disabled = !buttonRestart
	
	$Continue.visible = buttonContinue
	$Continue.disabled = !buttonContinue
	
	$Next.visible = buttonNext
	$Next.disabled = !buttonNext
	is_visible = true
	$AnimationPlayer.play("Appear")
	
func _on_Reset_pressed():
	if is_visible:
		restart = true
		$Sfx/Click.play()
		$Timer.start()

func _on_Continue_pressed():
	if is_visible:
		$Sfx/Click.play()
		get_node("/root/Game").paused = false
		is_visible = false
		$AnimationPlayer.play_backwards("Appear")

func _on_Next_pressed():
	if is_visible:
		restart = false
		$Sfx/Click.play()
		$Timer.start()
	
func _input(event):
	if !is_visible:
		return
		
	if $Next.visible and Input.is_action_just_pressed("ui_accept"):
		_on_Next_pressed()
	
	if $Continue.visible and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel")):
		_on_Continue_pressed()
		
	if $Reset.visible and Input.is_action_just_pressed("ui_accept"):
		_on_Reset_pressed()


func _on_Timer_timeout():
	if restart:
		LevelSwitcher.restart_level()
	else:
		LevelSwitcher.next_level()

func _on_btn_mouse_entered():
	$Sfx/Hover.play()

func _on_btn_mouse_exited():
	$Sfx/Hover.play()
