extends Node

@onready var end_turn_button: Button = $"../EndTurnButton"
@onready var enemy_deck: Node2D = $"../EnemyDeck"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var enemy_hand: Node2D = $"../EnemyHand"
@onready var deck: Node2D = $"../Deck"
@onready var card_manager: Node2D = $"../CardManager"


const CARD_SMALLER_SCALE = 0.06
const CARD_MOVE_SPEED = 0.2

var empty_monster_card_slots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot1")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")


func _on_end_turn_button_pressed() -> void:
	opponent_turn()


func opponent_turn():
	end_turn_button.disabled = true
	end_turn_button.visible = false
	
	# Wait 1 sec
	battle_timer.start()
	await battle_timer.timeout
	
	# If can draw a card, draw then wait 1 sec
	if enemy_deck.enemy_deck.size() != 0:
		enemy_deck.draw_card()
		battle_timer.start()
		await battle_timer.timeout
	
	# Check if there is free slots, and if not then end turn
	if empty_monster_card_slots.size() == 0:
		end_opponent_turn()
		return
	
	# Try to play a card
	await play_card()
	
	# End turn
	end_opponent_turn()


func play_card():
	# Check if there is card to play
	enemy_hand.enemy_hand
	if enemy_hand.enemy_hand.size() == 0:
		end_opponent_turn()
		return
	
	# Get a random empty slot to play the card in
	var random_empty_monster_card_slot = empty_monster_card_slots[randi_range(0, empty_monster_card_slots.size() - 1)]
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	
	# Play card with the hightest attack
	# Assume the first card has the highest atk
	var card_with_highest_atk = enemy_hand.enemy_hand[0]
	for card in enemy_hand.enemy_hand:
		if card.attack > card_with_highest_atk.attack:
			card_with_highest_atk = card
	
	var tween = get_tree().create_tween()
	tween.tween_property(card_with_highest_atk, "position", random_empty_monster_card_slot.position, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_with_highest_atk, "scale", Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE), CARD_MOVE_SPEED)
	card_with_highest_atk.get_node("AnimationPlayer").play("card_flip")
	
	# Remove card from enemy hand
	enemy_hand.remove_card_from_hand(card_with_highest_atk)
	
	# Wait 1 sec
	battle_timer.start()
	await battle_timer.timeout


func end_opponent_turn():
	end_turn_button.disabled = false
	end_turn_button.visible = true
	
	# Reset player deck draw and cards played
	deck.reset_draw()
	card_manager.reset_played_monster()
