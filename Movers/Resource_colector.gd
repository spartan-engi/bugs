extends Mover

export var inventory_space : int
export var inventory_id : int
export var inventory_fullness : int

#AIs
func task_is_inventory_full(task)->void:
	if inventory_fullness < inventory_space:
		task.failed()
	else:
		target = get_parent()
		update_target_location()
		task.succeed()
	return

func task_dump_cargo(task)->void:
	inventory_id = 0
	inventory_fullness = 0
	return
