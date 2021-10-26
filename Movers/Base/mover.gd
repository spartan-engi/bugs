extends RigidBody

class_name Mover

signal died

enum state {IDLE, MOVE, ACT, DIE}

onready var radar = $"Radar"

export var smol_squared_dist :  float = 9

export var accelForce : float = 15
export var accelMax : float = 30
export var target_group : String

export var max_integrity : int = 20 setget set_max_integrity
export var radar_reach : int = 20 setget set_radar_reach
export var interaction_reach : int = 4 setget set_interaction_reach

var dead : bool = false
var current_state : int = state.IDLE
var integrity : int = 20
var target : Spatial = null
var accelDirection : Vector3 = Vector3.ZERO



#func _physics_process(_delta):
#	match current_state:
#		state.IDLE:
#			pass
#		state.MOVE:
#			update_target_location()
#		state.ACT:
#			accelDirection = Vector3.ZERO
#			_act_on_target(target)
#		state.DIE:
#			emit_signal("died")
#	return

func _integrate_forces(_state):
	if accelDirection == Vector3.ZERO:
		add_central_force((-linear_velocity).normalized()*accelForce)
		return
	look_at(to_global(Vector3(accelDirection.x,0,accelDirection.z)), Vector3.UP)
	add_central_force(accelDirection*accelForce)
	if linear_velocity.length() > accelMax:
		linear_velocity = linear_velocity.normalized()*accelMax
	return

func set_radar_reach(new_reach : int)->void:
	$Radar/CollisionShape.shape.radius = float(new_reach)
	return
func set_interaction_reach(new_interaction : int)->void:
	$InteractionReach/CollisionShape.shape.radius = float(new_interaction)
	return
func set_max_integrity(new : int):
	max_integrity = new
	return

func update_target_location():
	if target == null:
		accelDirection = Vector3.ZERO
		return
	accelDirection = to_local(target.translation).normalized()
	return

func _on_Radar_area_entered(area):
	if area.is_in_group(target_group):
		if target != null and translation.distance_squared_to(area.translation)>translation.distance_squared_to(target.translation):
			return
		target = area
		current_state = state.MOVE
	return

func _on_InteractionReach_area_entered(area):
	if area.is_in_group(target_group):
		target = area
		current_state = state.ACT
	return

func _act_on_target(_target):
	pass

func die()->void:
	queue_free()
	return

#AIs
func task_is_dead(task)->void:
	if dead:
		task.succeed()
		die()
	else:
		task.failed()
	return

func task_request_target(task)->void:
	target = get_parent().request_target(target_group)
	
	if target == null:
		task.failed()
		return
	task.succeed()
	return

func task_wait_untill_is_at_target(task)->void:
	if translation.distance_squared_to(target.translation) < smol_squared_dist:
		task.succeed()
	return
