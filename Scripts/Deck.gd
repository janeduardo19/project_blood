extends Node2D

@onready var card_manager: Node2D = $"../CardManager"
@onready var player_hand: Node2D = $"../PlayerHand"
@onready var deck_image: Sprite2D = $DeckImage
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel

const CARD_DRAWN_SPEED = 0.2
const CARD_DATABASE = preload("res://Scripts/CardDatabase.gd")
const CARD_SCENE_PATH = "res://Scenes/Board/Card.tscn"
const STARTING_HAND_SIZE = 5

var player_deck = ["Erika", "Nixy", "Sualk", "Ozzy", "Nixy", "Sualk", "Erika", "Nixy", "Sualk", "Ozzy", "Nixy", "Sualk"]
var drawn_card_this_turn = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	rich_text_label.text = str(player_deck.size())
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	drawn_card_this_turn = true


func draw_card():
	if drawn_card_this_turn:
		return
	
	drawn_card_this_turn = true
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() == 0:
		collision_shape_2d.disabled = true
		deck_image.visible = false
		rich_text_label.visible = false
	
	rich_text_label.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/CardImages/" + card_drawn_name + ".png")
	var card_color_path = str("res://Assets/CardLayout/" + str(CARD_DATABASE.CARDS[card_drawn_name][0]) + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("CardColor").texture = load(card_color_path)
	new_card.get_node("Attack").text = str(CARD_DATABASE.CARDS[card_drawn_name][1])
	new_card.get_node("Health").text = str(CARD_DATABASE.CARDS[card_drawn_name][2])
	new_card.card_type = CARD_DATABASE.CARDS[card_drawn_name][3]
	card_manager.add_child(new_card)
	new_card.name = "Card"
	player_hand.add_card_to_hand(new_card, CARD_DRAWN_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")


func reset_draw():
	drawn_card_this_turn = false
