extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var SERVER_PORT = 8888
var MAX_PLAYERS = 8


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	OS.set_window_size(OS.get_window_size() * 6)
	OS.set_window_position(OS.get_window_position() - OS.get_window_size()/2)
	


func start_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
