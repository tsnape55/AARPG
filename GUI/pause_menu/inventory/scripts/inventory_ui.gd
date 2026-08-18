class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("uid://dr2o0r1ocwsg4")

var focus_index: int = 0

@export var data: InventoryData

func _ready() -> void:
	PauseMenu.shown.connect(update_inventory)
	PauseMenu.hidden.connect(clear_inventory)
	clear_inventory()
	data.changed.connect(on_inventory_changed)
	pass
	
func clear_inventory() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
		
func update_inventory(i : int = 0) -> void:
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
		new_slot.focus_entered.connect(item_focused)
		
	await get_tree().process_frame
	if get_child_count() > 0:
		var index := clampi(i, 0, get_child_count() - 1)
		get_child(index).grab_focus()

func on_inventory_changed() -> void:
	clear_inventory()
	update_inventory(focus_index)
	
func item_focused() -> void:
	for i in get_child_count():
		if get_child(i).has_focus():
			focus_index = i
			return
	pass
