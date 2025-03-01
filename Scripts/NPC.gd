extends CharacterBody2D

class_name NPC


@export var npc_name: String = "NPC"
@export var dialogic_timeline: String = "default_timeline"
@export var npc_texture: Texture2D 
@onready var sprite: Sprite2D = $Sprite2D

signal can_interact(is_interactable: bool)

var is_player_in_range: bool = false

func _ready():
	if npc_texture:
		sprite.texture = npc_texture
		
	# Conecte o sinal de interação com o jogador
	connect("can_interact", Callable(self, "_on_can_interact"))
	
	Dialogic.signal_event.connect(dialogic_signal)

func _process(delta):
	# Verifique se o jogador está dentro do alcance de interação
	if is_player_in_range and Input.is_action_just_pressed("interact"):
		start_dialogic_timeline()

func start_dialogic_timeline():
	# Inicie a timeline do Dialogic 2
	Dialogic.start(dialogic_timeline)

func _on_can_interact(is_interactable: bool):
	# Atualize o estado de interação do NPC
	is_player_in_range = is_interactable

func _on_interaction_area_body_entered(body):
	# Verifique se o corpo que entrou na área é o jogador
	if body.is_in_group("player"):
		emit_signal("can_interact", true)

func _on_interaction_area_body_exited(body):
	# Verifique se o corpo que saiu da área é o jogador
	if body.is_in_group("player"):
		emit_signal("can_interact", false)


func dialogic_signal(argument:String):
	if argument == "start_card_game":
		print("Sinal 'start_card_game' recebido")
		get_tree().change_scene_to_file("res://Scenes/Board/Board.tscn")
		
