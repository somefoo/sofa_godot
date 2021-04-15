tool
extends Button
#class_name MyButton, "res://addons/sofa_scene_creator/icon_sofa_yellow.png"

func _enter_tree():
	connect("pressed", self, "clicked")


func clicked():
	print("You clicked me!")
