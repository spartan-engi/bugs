extends Spatial

export var map_seed : int = 0
export var mapsize : Vector2 = Vector2(200,200)
export var mapzoomout : float = 75

export(float, -1, 1) var pebble : float = 0.36
export(float, -1, 1) var stone : float = 0.34
export(float, -1, 1) var metal : float = 0.54
export(float, -1, 1) var rare : float = 0.6

onready var mapy := $"Control/ViewportContainer/Viewport/Navigation2D/TileMap"
onready var grid := $"GridMap"
onready var ground := $"GridMap/Soil"
onready var player := $"Player"
onready var mapcam := $"Control/ViewportContainer/Viewport/Camera2D"
onready var playerindicator :=$"Control/ViewportContainer/Viewport/Camera2D/indicator"

var terrain_noise : OpenSimplexNoise
var metal_noise : OpenSimplexNoise
var rare_noise : OpenSimplexNoise

func _ready():
	map_seed = randi()
	terrain_noise = config_noise(metal_noise, map_seed, 1, 16.0, 0.5, 2.0)
	metal_noise = config_noise(metal_noise, map_seed+2, 1, 16.0, 0.5, 2.0)
	rare_noise = config_noise(metal_noise, map_seed+4, 1, 16.0, 0.5, 2.0)
	
	mapy.scale = Vector2.ONE/mapzoomout
	
	$"Control2/VBoxContainer/HSlider".value = pebble
	$"Control2/VBoxContainer/HSlider2".value = stone
	$"Control2/VBoxContainer/HSlider3".value = metal
	$"Control2/VBoxContainer/HSlider4".value = rare
	
	gen_mesh()
	
	$MainFrame/AnimationPlayer.play("deploying")
	return

func gen_mesh()->void:
	mapy.clear()
	playerindicator.rect_pivot_offset = (playerindicator.rect_size)/2
	grid.clear()
	ground.mesh.size = 2*mapsize
	
	for x in range(-mapsize.x, mapsize.x):
		for y in range(-mapsize.y, mapsize.y):
			var tille : int = determine_tile(terrain_noise.get_noise_2d(x,y), metal_noise.get_noise_2d(x,y), rare_noise.get_noise_2d(x,y))
			mapy.set_cell(x, y, fix_tile(tille))
			if tille != 0:
				grid.set_cell_item(x, 0, y, tille)
#			grid.set_cell_item(x, -1, y, 0)
	return

func _physics_process(_delta):
	mapcam.position = Vector2(player.translation.x, player.translation.z)*200/mapzoomout
	playerindicator.set_rotation(-player.get_rotation().y)
	return

func config_noise(noise : OpenSimplexNoise, seedy : int, octaves : int, period : float, persistence : float, lacunarity : float)->OpenSimplexNoise:
	noise = OpenSimplexNoise.new()
	
	noise.seed = seedy
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	
	return noise

func fix_tile(intake : int)->int:
	if intake == 0:
		return 0
	return int(intake/3.0)+1

func determine_tile(terrain : float, metalore : float, rareearth : float)->int:
	
	if terrain > pebble:
		return int(round(1+terrain))
	if terrain > stone:
		return int(round(4+terrain))
	if metalore > metal:
		return int(round(7+terrain))
	if rareearth > rare:
		return int(round(10+terrain))
	return 0


func _on_Player_quit():
	get_tree().quit()
	return

func _on_regen_pressed():
	pebble = $"Control2/VBoxContainer/HSlider".value
	stone = $"Control2/VBoxContainer/HSlider2".value
	metal = $"Control2/VBoxContainer/HSlider3".value
	rare = $"Control2/VBoxContainer/HSlider4".value
	gen_mesh()
	return

func _on_max_pressed():
	mapzoomout = mapzoomout - 10
	if mapzoomout < 1:
		mapzoomout = 10
	mapy.scale = Vector2.ONE/mapzoomout
	return

func _on_minus_pressed():
	mapzoomout = mapzoomout + 10
	mapy.scale = Vector2.ONE/mapzoomout
	return
