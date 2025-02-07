extends CharacterBody2D

# Definindo o nome da classe para identificar o tipo de corpo em Area2D
class_name Player

@onready var camera_2d: Camera2D = $Camera2D

const SPEED = 400.0

func _ready():
	camera_2d.make_current()
	setup_camera_limits() 

func _physics_process(delta: float) -> void:
	var velocity = Vector2.ZERO  # Vetor de movimento do jogador

	# Movimento baseado em input
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1

	# Normaliza a velocidade e aplica a velocidade constante
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.stop()

	# Inverte a imagem do jogador se estiver se movendo para a esquerda
	if velocity.x > 0:
		$Image.flip_h = false
	elif velocity.x < 0:
		$Image.flip_h = true

	# Aplica o movimento usando move_and_slide
	position += velocity * delta
	move_and_slide()


func setup_camera_limits():
	# Assume que o fundo do mapa é uma Sprite2D chamada "Background"
	var background = get_parent().get_node("Background") as Sprite2D
	if background:
		var texture_size = background.texture.get_size()  # Tamanho da textura do fundo
		camera_2d.limit_left = 0
		camera_2d.limit_right = texture_size.x
		camera_2d.limit_top = 0
		camera_2d.limit_bottom = texture_size.y
	else:
		print("Background not found for camera limits.")
