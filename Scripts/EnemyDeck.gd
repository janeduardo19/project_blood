extends Node2D

@onready var card_manager: Node2D = $"../CardManager"
@onready var enemy_hand: Node2D = $"../EnemyHand"
@onready var deck_image: Sprite2D = $DeckImage
@onready var rich_text_label: RichTextLabel = $RichTextLabel

const CARD_DRAWN_SPEED = 0.2
const CARD_DATABASE = preload("res://Scripts/CardDatabase.gd")
const CARD_SCENE_PATH = "res://Scenes/Battle/EnemyCard.tscn"
const STARTING_HAND_SIZE = 5

var enemy_deck = ["Ozzy", "Nixy", "Ozzy", "Nixy", "Erika", "Sualk"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_deck.shuffle()
	rich_text_label.text = str(enemy_deck.size())
	for i in range(STARTING_HAND_SIZE):
		draw_card()


func draw_card():
	var card_drawn_name = enemy_deck[0]
	enemy_deck.erase(card_drawn_name)
	
	if enemy_deck.size() == 0:
		deck_image.visible = false
		rich_text_label.visible = false
	
	rich_text_label.text = str(enemy_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/CardImages/" + card_drawn_name + ".png")
	var card_color_path = str("res://Assets/CardLayout/" + str(CARD_DATABASE.CARDS[card_drawn_name][0]) + ".png")
	new_card.card_name = card_drawn_name
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("CardColor").texture = load(card_color_path)
	new_card.attack = CARD_DATABASE.CARDS[card_drawn_name][1]
	new_card.get_node("Attack").text = str(new_card.attack)
	new_card.health = CARD_DATABASE.CARDS[card_drawn_name][2]
	new_card.get_node("Health").text = str(new_card.health)
	new_card.card_type = CARD_DATABASE.CARDS[card_drawn_name][3]
	card_manager.add_child(new_card)
	new_card.name = "Card"
	enemy_hand.add_card_to_hand(new_card, CARD_DRAWN_SPEED)
