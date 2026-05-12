extends Node

const SCRIPT_OBJ_DATA_CONSTS = preload("res://src/scripts/obj_data_consts.gd")

static func debug_data_dict(obj_caller: Node) -> void:
	print("\n>>DEBUG_PRINT: 'obj_data' from Node", obj_caller.name, "'")
	var obj_data: Dictionary = get_data_dict(obj_caller)
	for data in obj_data.keys():
		print(SCRIPT_OBJ_DATA_CONSTS.DATA_ENUMS.keys()[data], " : ", obj_data[data], " TYPE> ", Globals.get_vartype_string_from_var(obj_data[data]))

static func get_data_dict(from_obj: Node) -> Dictionary:
	return from_obj.obj_data

static func get_data_value(from_obj: Node, key: int) -> Variant:
	return from_obj.obj_data[key]

static func has_data_key(from_obj: Node, key: int) -> bool:
	return (from_obj.obj_data as Dictionary).has(key)

static func set_data_value(from_obj: Node, key: int, new_data_value: Variant) -> void:
	if has_data_key(from_obj, key):
		var current_var: Variant = from_obj.obj_data[key]
		if typeof(current_var) != typeof(new_data_value):
			push_error(
				"\n>>Type mismatch: For set_data_value()! for object: ", from_obj.name,
				"\n>>Expected '", Globals.get_vartype_string_from_var(current_var), "' but got '", Globals.get_vartype_string_from_var(new_data_value),
				"\n<--->Key Enum Int: ", key,
				"\n<--->Old_Var: ", from_obj.obj_data[key],
				"\n<--->New_Var: ", new_data_value
			)
			return
	from_obj.obj_data[key] = new_data_value

static func add_data_value(from_obj: Node, key: int, new_data_value: Variant) -> void:
	if has_data_key(from_obj, key):
		var expected_array: Variant = get_data_value(from_obj, key)
		if expected_array is Array:
			if (expected_array as Array).find(new_data_value):
				return
			else:
				(from_obj.obj_data[key] as Array).append(new_data_value)
	set_data_value(from_obj, key, new_data_value)
