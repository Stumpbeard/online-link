extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 16
var direction = 'right'
var moving = false
var roll = 0
var spawning = false
var dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	spawning = true
	$AnimatedSprite.play("cloud")
	yield(get_tree().create_timer(1), "timeout")
	$AnimatedSprite.play("default")
	spawning = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !is_network_master():
		return
	if spawning or dead:
		return
	if !moving:
		roll = randi() % 6
		

	rpc('handle_roll', roll)
	
remotesync func handle_roll(local_roll):
	if dead:
		return
	roll = local_roll
	if $DecisionTimer.is_stopped():
		$DecisionTimer.start(2)
		moving = true

	var move = Vector2()
	if roll == 0:
		move.x -= 1
		direction = 'left'
	if roll == 1:
		move.x += 1
		direction = 'right'
	if roll == 2:
		move.y -= 1
		direction = 'up'
	if roll == 3:
		move.y += 1
		direction = 'down'
		
	if roll == 5:
		var rock = load("res://Rock.tscn").instance()
		moving = true
		rock.position = position
		match direction:
			'right':
				rock.dir = Vector2(1, 0)
			'left':
				rock.dir = Vector2(-1, 0)
			'down':
				rock.dir = Vector2(0, 1)
			'up':
				rock.dir = Vector2(0, -1)
		roll = 4
		get_parent().get_parent().add_child(rock)

	move = move.normalized()
	move_and_slide(move * speed)
	if move.x < 0:
		$AnimatedSprite.rotation_degrees = 180
	elif move.x > 0:
		$AnimatedSprite.rotation_degrees = 0
	if move.y < 0:
		$AnimatedSprite.rotation_degrees = 270
	elif move.y > 0:
		$AnimatedSprite.rotation_degrees = 90
	if move != Vector2():
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("default")
		
	var collisions = get_slide_count()
	if collisions > 0:
		var col = get_slide_collision(0)
		position += col.normal
		roll = 4

func _on_DecisionTimer_timeout():
	moving = false

func is_enemy():
	return true and !(spawning or dead)
	
func handle_death():
	rpc('die')
	
remotesync func die():
	if spawning:
		return
	dead = true
	$CollisionShape2D.disabled = true
	$AnimatedSprite.play("cloud")
	yield(get_tree().create_timer(1), "timeout")
	visible = false


func serialize():
	return {
		"position": position,
		"spawning": spawning,
		"moving": moving,
		"dead": dead,
		"direction": direction
	}

func deserialize(data):
	position = Vector2(data["position"])
	spawning = data["spawning"]
	moving = data["moving"]
	dead = data["dead"]
	direction = data["direction"]
	if dead:
		visible = false
		$CollisionShape2D.disabled = true
