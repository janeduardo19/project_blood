extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	call_deferred("change_map")


func change_map():
	Global.from_world = get_parent().name
	get_tree().change_scene_to_file("res://Scenes/World/" + name + ".tscn")
