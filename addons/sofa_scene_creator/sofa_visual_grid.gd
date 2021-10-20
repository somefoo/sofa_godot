tool
extends Spatial

const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")
const SofaUtility = preload("res://addons/sofa_scene_creator/sofa_utility.gd")


export(String, "Axis+Grid","Axis","Grid") var visual_type = "Axis+Grid"
#export(float, 1, 16) var thickness = 1
var thickness = 1
export(Color) var color = Color(1,1,1,1)
export(String, "X", "Y", "Z") var plane = "Y"
export(float, 30000) var size = 10.0
export(int, 2, 128, 2) var subdivisions = 16



func get_xml_tree():
	var xml_base = XMLSceneTree.new()
	xml_base.get_root().add_properties({"name":get_name()})
	if visual_type == "Axis+Grid" or visual_type == "Grid":
		xml_base.get_root().add_child("OglGrid").add_properties({"name":"Grid", "thickness":thickness, "color":color, "plane":plane, "size":size, "nbSubdiv":subdivisions})
	if visual_type == "Axis+Grid" or visual_type == "Axis":
		xml_base.get_root().add_child("OglLineAxis").add_properties({"name":"Axis", "size":size})
		
	
	return xml_base



func _process(delta):
	if visual_type == "Axis+Grid" or visual_type == "Grid":
		var step_size = size / subdivisions
		for h in range (-subdivisions/2, subdivisions/2 + 1):
			if visual_type == "Axis+Grid" and h == 0:
				continue
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
	if visual_type == "Axis+Grid" or visual_type == "Axis":
		SofaUtility.draw_line(self, Vector3(-size/2,0,0), Vector3(size/2,0,0), SofaUtility.COLOR_RED)
		SofaUtility.draw_line(self, Vector3(0,-size/2,0), Vector3(0,size/2,0), SofaUtility.COLOR_GREEN)
		SofaUtility.draw_line(self, Vector3(0,0,-size/2), Vector3(0,0,size/2), SofaUtility.COLOR_BLUE)
		
	
	scale = Vector3(0,0,0)
	translation = Vector3(0,0,0)
	rotation = Vector3(0,0,0)
