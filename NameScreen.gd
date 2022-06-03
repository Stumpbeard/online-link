extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


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
			var game = load('res://Game.tscn').instance()
			game.change_name($TextEdit.text)
			get_parent().add_child(game)
			get_tree().set_input_as_handled()
			queue_free()
