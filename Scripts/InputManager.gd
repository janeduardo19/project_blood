extends Node2D

@onready var card_manager: Node2D = $"../CardManager"
@onready var deck: Node2D = $"../Deck"
@onready var camera_manager: Node2D = $"../CameraManager"


signal  left_mouse_button_clicked
signal  left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4
const COLLISION_MASK_ENEMY_CARD = 8

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")
	
	# Change camera with button
	if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("scroll_up"):
		camera_manager.is_front_view = true
		camera_manager.toggle_camera()
	
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("scroll_down"):
		camera_manager.is_front_view = false
		camera_manager.toggle_camera()

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# return result[0].collider.get_parent()
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found = get_card_with_highest_z_index(result)
			if card_found:
				card_manager.card_clicked(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			# Deck clicked
			deck.draw_card()
		elif result_collision_mask == COLLISION_MASK_ENEMY_CARD:
			$"../BattleManager".enemy_card_selected(result[0].collider.get_parent())



func get_card_with_highest_z_index(cards):
	# Assume the first card in cards array has the hightest z index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# Loop throug the rest of the cards checking for a higher z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card 
