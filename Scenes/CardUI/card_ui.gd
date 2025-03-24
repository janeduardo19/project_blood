class_name CardUI
extends Control

signal reparent_requested(which_card_ui: CardUI)
signal hovered
signal hovered_off


@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label


var starting_position
var card_slot_card_is_in
var card_type
var card_name
var attack
var health
var defeated = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All cards must be child of CardManager or this will error
	var card_manager = CardManager.new()
	card_manager.connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
