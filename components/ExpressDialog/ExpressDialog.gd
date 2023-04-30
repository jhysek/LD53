extends Panel

func _ready():
	visible = false
	set_process_input(true)
	
func showDialog(msg, buttonRestart, buttonContinue, buttonNext):
	$info.text = msg
	$Reset.visible = buttonRestart
	$Reset.disabled = !buttonRestart
	
	$Continue.visible = buttonContinue
	$Continue.disabled = !buttonContinue
	
	$Next.visible = buttonNext
	$Next.disabled = !buttonNext
	visible = true
	
func _on_Reset_pressed():
	if visible:
		LevelSwitcher.restart_level()

func _on_Continue_pressed():
	if visible:
		get_node("/root/Game").paused = false
		hide()

func _on_Next_pressed():
	if visible:
		LevelSwitcher.next_level()
	
func _input(event):
	if !visible:
		return
		
	if $Next.visible and Input.is_action_just_pressed("ui_accept"):
		_on_Next_pressed()
	
	if $Continue.visible and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel")):
		_on_Continue_pressed()
		
	if $Reset.visible and Input.is_action_just_pressed("ui_accept"):
		_on_Reset_pressed()
