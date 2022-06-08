extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var button_pressed = false
var button_hovered = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$TextEdit.grab_focus()
	$TextEdit.cursor_set_column(4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_TextEdit_text_changed():
	if $TextEdit.text.length() > 4:
		$TextEdit.text = $TextEdit.text.substr(0, 4)
		$TextEdit.cursor_set_column(4)
		
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			get_parent().start_game($TextEdit.text)
			get_tree().set_input_as_handled()
			queue_free()

func _on_ToggleButton_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			button_pressed = !button_pressed
			if button_pressed:
				$ToggleButton/AnimatedSprite.play("pressed")
				$ToggleButton/IPInput.visible = true
			else:
				$ToggleButton/AnimatedSprite.play("default")
				$ToggleButton/IPInput.visible = false
