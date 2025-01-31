extends Area2D

class_name Door

# Destination scene
@export var destination_level_tag: String

# Identification of the door, cause we can have more than one in the same scene
@export var destination_door_tag: String

@export var spawn_direction = "up"

@onready var spawn = $Spawn

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		NavigationManager.go_to_map(destination_level_tag, destination_door_tag)
