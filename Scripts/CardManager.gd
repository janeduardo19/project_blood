extends Node2D

@onready var player_hand: Node2D = $"../PlayerHand"
@onready var input_manager: Node2D = $"../InputManager"

#signal on_left_click_pressed
#signal on_left_click_released

const COLLISION_CARD_MASK = 1
const COLLISION_CARD_MASK_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_SCALE = 0.07
const HIGHLIGHT_SCALE = 0.08
const CARD_SMALLER_SCALE = 0.06


var screen_size
var card_being_dragged
var is_hovering_on_card
var played_monster_card_this_turn = false
var selected_monster


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	input_manager.connect("left_mouse_button_released", on_left_click_released)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
		clamp(mouse_pos.y, 0, screen_size.y))


func card_clicked(card):
	if card.card_slot_card_is_in and $"../BattleManager".is_enemy_turn == false:
		if $"../BattleManager".player_is_attacking == false:
			if card not in $"../BattleManager".player_cards_that_attacked_this_turn:
				if $"../BattleManager".enemy_card_on_battlefield.size() == 0:
					$"../BattleManager".direct_attack(card, "Player")
					return
				else:
					select_card_for_battle(card)
	else:
		start_drag(card)


func select_card_for_battle(card):
	if selected_monster:
		if selected_monster == card:
			card.position.y += 20
			selected_monster = null
		else:
			selected_monster.position.y += 20
			selected_monster = card
			card.position.y -= 20
	else:
		selected_monster = card
		card.position.y -= 20


func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(DEFAULT_SCALE, DEFAULT_SCALE)
	card.z_index = 2


func finish_drag():
	card_being_dragged.scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)
	
	var card_slot_found = raycast_check_for_card_slot()
	
	if card_slot_found and not card_slot_found.card_in_slot:
		# If card can be placed in this slot
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			if !played_monster_card_this_turn:
				played_monster_card_this_turn = true
				# Card dropped in empty card slot
				card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
				card_being_dragged.z_index = -1
				is_hovering_on_card = false
				card_being_dragged.card_slot_card_is_in = card_slot_found
				player_hand.remove_card_from_hand(card_being_dragged)
				# Card drooped in card slot
				card_being_dragged.position = card_slot_found.position
				card_slot_found.card_in_slot = true
				card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
				$"../BattleManager".player_cards_on_battlefield.append(card_being_dragged)
				card_being_dragged = null
				return
	player_hand.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_left_click_released():
	if card_being_dragged:
		finish_drag()


func on_hovered_over_card(card):
	if card.card_slot_card_is_in:
		return
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


func on_hovered_off_card(card):
	if !card.defeated:
		# Check if card is NOT in a card slot AND NOT being dragged
		if !card.card_slot_card_is_in && !card_being_dragged:
			# If not dragging
			highlight_card(card, false)
			# Check if hovered off card straight on to another card
			var new_card_hovered = raycast_check_for_card()
			if new_card_hovered:
				highlight_card(new_card_hovered, true)
			else:
				is_hovering_on_card = false


func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(HIGHLIGHT_SCALE, HIGHLIGHT_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_SCALE, DEFAULT_SCALE)
		card.z_index = 1


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_CARD_MASK_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_CARD_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null


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


func reset_played_monster():
	played_monster_card_this_turn = false


func unselect_monster():
	if selected_monster:
		selected_monster.position.y += 20
		selected_monster = null
