extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var SERVER_PORT = 8888
var MAX_PLAYERS = 8
var SERVER_IP = 'localhost'

var player_info = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	OS.set_window_size(OS.get_window_size() * 6)
	OS.set_window_position(OS.get_window_position() - OS.get_window_size()/2)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("connected_to_server", self, "_connected_ok")

func start_server():
	print("started server")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	$Timer.start(3)
	
func start_client():
	print("started client")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer

func _connected_fail():
	print("failed connect")
	
func _connected_ok():
	print("it worked")
	
func _player_connected(id):
	print("player connected")
	if is_network_master():
		var player = load("res://Link.tscn").instance()
		player.position = Vector2(44, 44)
		player.set_name(str(id))
		get_node("Game").add_child(player)
		player_info[str(id)] = player
		sync_players()
		sync_enemies()


func start_game(player_name):
	if !$NameScreen.button_pressed:
		start_server()
	else:
		start_client()
	var game = load('res://Game.tscn').instance()
	game.change_name(player_name)
	add_child(game)
	
func sync_players():
	for id in player_info:
		rpc('upsert_player', id, player_info[id].serialize())
		
func sync_enemies():
	for enemy in get_node("Game/Enemies").get_children():
		rpc('upsert_enemy', enemy.get_name(), enemy.serialize())
		
		
remote func upsert_player(id, player):
	var game = get_node("Game")
	if !game.get_node(id):
		var new_player = load("res://Link.tscn").instance()
		new_player.set_name(id)
		new_player.deserialize(player)
		game.add_child(new_player)
	else:
		game.get_node(id).deserialize(player)
		
remote func upsert_enemy(id, enemy_data):
	var game = get_node("Game")
	var enemy = game.get_node("Enemies/%s" % id)
	enemy.deserialize(enemy_data)


func _on_Timer_timeout():
	sync_players()
	sync_enemies()
