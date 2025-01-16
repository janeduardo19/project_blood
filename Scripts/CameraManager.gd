extends Node2D

# Background changes
@onready var top_down: Sprite2D = $"../Background/TopDown"
@onready var front_view: Sprite2D = $"../Background/FrontView"


# Nodes to be oculted
@onready var player_hand: Node2D = $"../PlayerHand"
@onready var enemy_hand: Node2D = $"../EnemyHand"
@onready var end_turn_button: Button = $"../EndTurnButton"

# Distorted nodes
@onready var card_slots: Node2D = $"../CardSlots"
@onready var deck: Node2D = $"../Deck"
@onready var enemy_deck: Node2D = $"../EnemyDeck"

@export var transition_speed: float = 0.1
var is_front_view: bool = false

func toggle_camera():
	update_background()
	update_ui_visibility()
	update_card_distortion()


func update_background():
	# Change background to seem like a camera change
	if is_front_view:
		top_down.visible = false
		front_view.visible = true
	else:
		top_down.visible = true
		front_view.visible = false


func update_ui_visibility():
	# Ocult what we dont want the player to see in front view
	if is_front_view:
		$"../CardManager".visible = false
		end_turn_button.visible = false
	else:
		$"../CardManager".visible = true
		end_turn_button.visible = true

func update_card_distortion():
	# Trying to change scale automatically
	var scale_card_slots = Vector2(0.45, 0.22) if is_front_view else Vector2(0.45, 0.45)
	var scale_deck = Vector2(0.07, 0.03) if is_front_view else Vector2(0.07, 0.07)
	var scale_enemy_deck = Vector2(0.045, 0.02) if is_front_view else Vector2(0.07, 0.07)
	var deck_position = Vector2(400, 649) if is_front_view else Vector2(80, 639)
	var enemy_deck_position = Vector2(770, 419) if is_front_view else Vector2(1200, 100)
	var rotation_deck = 0.05 if is_front_view else 0.0
	var rotation_enemy_deck = -0.05 if is_front_view else 0.0
	
	# Check all slots to distort them
	for slot in $"../CardSlots".get_children():
		slot.visible = false if is_front_view else true
	
	# Distort decks
	deck.scale = scale_deck
	deck.position = deck_position
	deck.rotation = rotation_deck
	$"../Deck/RichTextLabel".visible = false if is_front_view else true
	
	enemy_deck.scale = scale_enemy_deck
	enemy_deck.position = enemy_deck_position
	enemy_deck.rotation = rotation_enemy_deck
	$"../EnemyDeck/RichTextLabel".visible = false if is_front_view else true
