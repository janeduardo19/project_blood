extends Node


const scene_map1 = preload("res://Scenes/Map1.tscn")
const scene_map3 = preload("res://Scenes/Map3.tscn")

var spawn_door_tag

func go_to_map(map_tag, destination_tag):
	var scene_to_load
	
	match map_tag:
		"map1":
			scene_to_load = scene_map1
		"map3":
			scene_to_load = scene_map3
		
	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)
