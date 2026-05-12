extends Node

const SCRIPT_OBJ_DATA_CONSTS = preload("res://src/scripts/obj_data_consts.gd")
const ACTION_SCRIPTS: Dictionary[int, Script] = {
	SCRIPT_OBJ_DATA_CONSTS.ACTION_NAMES.ACTION_MOVE: preload("res://src/scripts/action_move.gd"),
	SCRIPT_OBJ_DATA_CONSTS.ACTION_NAMES.ACTION_SELECTABLE: preload("res://src/scripts/action_selectable.gd")
}

static func initialize_actions(obj_caller: Node, actions: Array[Script]) -> void:
	for action: Script in actions:
		action.initialize_action(obj_caller)
