extends Node

# Creates an action
func add_keybind(actionName:String, key: String) -> void:
	var event := InputEventKey.new()
	event.keycode = OS.find_keycode_from_string(key)
	InputMap.add_action(actionName)
	InputMap.action_add_event(actionName, event)

# Removes an action
func remove_keybind(actionName: String) -> void:
	InputMap.erase_action(actionName)
