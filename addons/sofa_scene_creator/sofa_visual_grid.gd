tool
extends Spatial

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")

export(float, 1, 16) var thickness = 1
export(Color) var color = Color(1,1,1,1)
export(String, "X", "Y", "Z") var plane = "Y"
export(float, 30000) var size = 10.0
export(int, 2, 128, 2) var subdivisions = 16


func get_xml_tree():
	var xml_grid = XMLSceneTree.new("OglGrid")
	var grid_root = xml_grid.get_root()
	grid_root.add_properties({"name":get_name(), "thickness":thickness, "color":color, "plane":plane, "size":size, "nbSubdiv":subdivisions})
	return xml_grid



func _process(delta):
	var step_size = size / subdivisions
	for h in range (-subdivisions/2, subdivisions/2 + 1):
		var a_beginning = Vector3(0,0,0)
		var a_end = Vector3(0,0,0)
		var b_beginning = Vector3(0,0,0)
		var b_end = Vector3(0,0,0)
		
		if(plane == "X"):
			a_beginning = Vector3(0,-size/2,h*step_size)
			a_end = Vector3(0,size/2,h*step_size)
			b_beginning = Vector3(0,h*step_size,-size/2)
			b_end = Vector3(0,h*step_size,size/2)
		
		elif(plane == "Y"):
			a_beginning = Vector3(-size/2,0,h*step_size)
			a_end = Vector3(size/2,0,h*step_size)
			b_beginning = Vector3(h*step_size,0,-size/2)
			b_end = Vector3(h*step_size,0,size/2)
			

		
		elif(plane == "Z"):
			a_beginning = Vector3(-size/2,h*step_size,0)
			a_end = Vector3(size/2,h*step_size,0)
			b_beginning = Vector3(h*step_size,-size/2,0)
			b_end = Vector3(h*step_size,size/2,0)
			
		SofaUtility.draw_line(self, a_beginning, a_end, color)
		SofaUtility.draw_line(self, b_beginning, b_end, color)
		
	
	scale = Vector3(0,0,0)
	translation = Vector3(0,0,0)
	rotation = Vector3(0,0,0)
