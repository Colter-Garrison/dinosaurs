extends Node

# Preload obstacles
var stump_scene = preload("res://src/Scenes/stump.tscn")
var rock_scene = preload("res://src/Scenes/rock.tscn")
var barrel_scene = preload("res://src/Scenes/barrel.tscn")
var bird_scene = preload("res://src/Scenes/bird.tscn")
var vine_scene = preload("res://src/Scenes/vine.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene, vine_scene]
var obstacles : Array
var bird_heights := [200, 390]
var vine_height := 0

# Game variables
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 10
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
# Reset variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
# Delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
# Reset the nodes
	$LokiDinosaur.position = DINO_START_POS
	$LokiDinosaur.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
# Reset HUD and game over screen 
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()
	$ThemeMusic.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = min(START_SPEED + score / SPEED_MODIFIER, MAX_SPEED)
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
	# Generate obstacles
		generate_obstacles()
	# Move dino and camera
		$LokiDinosaur.position.x += speed
		$Camera2D.position.x += speed
	# Update score
		score += speed
		show_score()
	# Update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
		# Remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("start"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obstacles():
	# Generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var effective_difficulty = min(difficulty, 3)
		var max_obs = effective_difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int
			if obs_type == vine_scene:
				obs_y = vine_height
			else:
				obs_y = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		# Additionaly random chance to spawn a bird
		if difficulty >= 2 and (randi() % 2) == 0:
			# Generate bird obstacles
			obs = bird_scene.instantiate()
			var obs_x : int = screen_size.x + score + 100
			var obs_y : int = bird_heights[randi() % bird_heights.size()]
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "LokiDinosaur":
		game_over()
		$HitSound.play()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGHSCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	$ThemeMusic.stop()

# 1152 x 648
