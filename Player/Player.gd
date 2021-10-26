extends KinematicBody

signal quit

export var speed = 30
export var mouse_mult = -0.004

export var spin = Vector3.ZERO
export var rot_speed = 0.03

var velocity = Vector3.ZERO
var direction = Vector3.ZERO

onready var quit = $"Pivot/Control/Esc"

onready var camera = $"Pivot"

onready var crosshair = $"Pivot/Control/Control/Crosshair"
onready var not_f3 = $"Pivot/Control/Label"

func _ready() -> void:
	crosshair.frame = 0
	return

func _input(event):
#	_update_cursor_position()
	if event is InputEventKey:
		if Input.is_action_just_pressed("camera_switch"):
			if $"Pivot/Camera".translation == Vector3(0,0,-0.5):
				$"Pivot/Camera".translation = Vector3(2,0.5,3.5)
			else:
				$"Pivot/Camera".translation = Vector3(0,0,-0.5)
		elif Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(0)
				quit.visible = true
			else:
				Input.set_mouse_mode(2)
				quit.visible = false
	elif event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			spin.y += event.relative.x*mouse_mult
			spin.x += event.relative.y*mouse_mult
#	elif event is InputEventMouseButton:
#		if not event.pressed:
#			match event.button_index:
#				BUTTON_LEFT:
#					if not raycast.is_colliding():
#						return
#					_world.set_voxel(_cursor_position+_cursor_normal, _block_id)
##						_world.update_chunk(_cursor_position+_cursor_normal)
#					block_animation.play("act")
#				BUTTON_RIGHT:
#					if not raycast.is_colliding():
#						return
#					_world.erase_voxel(_cursor_position)
##						_world.update_chunk(_cursor_position)
#					block_animation.play("act")
#				BUTTON_WHEEL_UP:
#					if is_instance_valid(_world):
#						_block_id = int(clamp(
#							_block_id + 1, 0, voxleset.size() - 1))
#						_update_block()
#				BUTTON_WHEEL_DOWN:
#					if is_instance_valid(_world):
#						_block_id = int(clamp(
#							_block_id - 1, 0, voxleset.size() - 1))
#						_update_block()


func _physics_process(delta):
	
	#determine univbersal inputs
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.z = Input.get_action_strength("move_back")  - Input.get_action_strength("move_forward")
	direction.y = Input.get_action_strength("move_up")  - Input.get_action_strength("move_down")
	
	#head rotation
	spin.x = clamp(spin.x, -1.5708, 1.5708)
	camera.rotation = Vector3(spin.x, 0, 0)
	
	#side rotation
	transform.basis = transform.basis.rotated(transform.basis.y, spin.y)
	
	spin.y = 0
#	spin.z = 0
	
#	if direction != Vector3.ZERO:
	direction = direction.normalized()
	direction = transform.basis.xform(direction)
	velocity = velocity.move_toward((direction*speed), delta*50)
	
	velocity = move_and_slide(velocity, transform.basis.y)
	


#func _update_cursor_position() -> void:
#
#	crosshair.frame = raycast.is_colliding()
#	cursor.visible = raycast.is_colliding()
#	if cursor.visible:
#		var pos := raycast.get_collision_point()
#		_cursor_normal = raycast.get_collision_normal()
#		_cursor_position = pos - _cursor_normal * (Voxel.VoxelWorldSize / 2)
#
#		var tran = _cursor_position + _cursor_normal
#		tran = to_local(tran)
#		cursor.translation = tran
#
#		not_f3.text = ("looking at:" + String(_world.position_proc(_cursor_position)) + "block XYZ" )


func _on_Back_pressed():
	emit_signal("quit")
	return
