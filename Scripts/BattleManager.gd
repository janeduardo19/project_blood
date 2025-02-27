extends Node

@onready var end_turn_button: Button = $"../EndTurnButton"
@onready var enemy_deck: Node2D = $"../EnemyDeck"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var enemy_hand: Node2D = $"../EnemyHand"
@onready var deck: Node2D = $"../Deck"
@onready var card_manager: Node2D = $"../CardManager"


const CARD_SMALLER_SCALE = 0.06
const CARD_MOVE_SPEED = 0.2
const STARTING_HEALTH = 10
const BATTLE_POS_OFFSET = 25

var empty_monster_card_slots = []
var opponent_card_on_battlefield = []
var player_cards_on_battlefield = []
var player_health
var enemy_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot1")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")
	
	player_health = STARTING_HEALTH
	$"../PlayerHealth".text = str(player_health)
	enemy_health = STARTING_HEALTH
	$"../EnemyHealth".text = str(enemy_health)


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
	
	# Check if there is free slots, and play monster with hightest attack
	if empty_monster_card_slots.size() != 0:
		await play_card()
	
	# Try to attack
	if opponent_card_on_battlefield.size() != 0:
		var enemy_cards_to_attack = opponent_card_on_battlefield.duplicate()
		for card in enemy_cards_to_attack:
			if player_cards_on_battlefield.size() != 0:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "Enemy")
			else:
				await direct_attack(card, "Enemy")
	
	if player_health <= 0:
		get_tree().change_scene_to_file("res://World/Level3.tscn")
	
	# End turn
	end_opponent_turn()


func play_card():
	# Check if there is card to play
	enemy_hand.enemy_hand
	if enemy_hand.enemy_hand.size() == 0:
		end_opponent_turn()
		return
	
	# Get a random empty slot to play the card in
	var random_empty_monster_card_slot = empty_monster_card_slots.pick_random()
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
	card_with_highest_atk.card_slot_card_is_in = random_empty_monster_card_slot
	opponent_card_on_battlefield.append(card_with_highest_atk)
	
	await wait(1.0)


func wait(wait_time):
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout


func end_opponent_turn():
	end_turn_button.disabled = false
	end_turn_button.visible = true
	
	# Reset player deck draw and cards played
	deck.reset_draw()
	card_manager.reset_played_monster()


func attack(attacking_card, defending_card, attacker):
	attacking_card.z_index = 5
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	
	defending_card.health = defending_card.health - attacking_card.attack
	defending_card.get_node("Health").text = str(defending_card.health)
	attacking_card.health = attacking_card.health - defending_card.attack
	attacking_card.get_node("Health").text = str(attacking_card.health)
	
	await wait(1.0)
	attacking_card.z_index = 1
	
	var card_was_destroyed = false
	
	# Destroy cards if health is 0
	if attacking_card.health <= 0:
		destroy_card(attacking_card, attacker)
		card_was_destroyed = true
	if defending_card.health <= 0:
		if attacker == "Player":
			destroy_card(defending_card, "Enemy")
		else:
			destroy_card(defending_card, "Player")
		card_was_destroyed = true
	
	if card_was_destroyed:
		await wait(1.0)


func direct_attack(attacking_card, attacker):
	var new_pos_y
	if attacker == "Enemy":
		new_pos_y = 1280
	else:
		new_pos_y = 50
	
	attacking_card.z_index = 5
	
	var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	
	if attacker == "Enemy":
		player_health = player_health - attacking_card.attack
		$"../PlayerHealth".text = str(player_health)
	else:
		enemy_health = enemy_health - attacking_card.attack
		$"../EnemyHealth".text = str(enemy_health)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, CARD_MOVE_SPEED)
	attacking_card.z_index = 1
	
	await wait(1.0)
	
	
func destroy_card(card, card_owner):
	var new_pos
	if card_owner == "Player":
		new_pos = $"../PlayerDiscard".position
	else:
		new_pos = $"../EnemyDiscard".position
	
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
