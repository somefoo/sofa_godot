tool
extends Spatial
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")

export(Array, NodePath) var fixed_constraints

var physics_object : bool = true
var movable : bool = true
var mass : float = 1.0

var soft_body : bool = false
var soft_body_poisson_ratio : float = 0.3
var soft_body_youngs_modulus : float = 18000.0

var cutable : bool = false

var visual_mesh : Mesh = CubeMesh.new()
var material = SpatialMaterial.new()
#onready var meshInstance = $Mesh
#export (SpatialMaterial) var material = SpatialMaterial.new()

func _enter_tree():
	#var preview_visual_mesh = MeshInstance.new()
	#preview_visual_mesh.mesh = visual_mesh
	#add_child(preview_visual_mesh)
	
	print("Sofa Object Entered Tree.")


func _get(property):
	if property == "mechanical/physics_object":
		return physics_object
	if property == "mechanical/physics_object_properties/movable":
		return movable
	if property == "mechanical/physics_object_properties/mass":
		return mass
		
	if property == "mechanical/physics_object_properties/soft_body":
		return soft_body
	if property == "mechanical/physics_object_properties/soft_body_properties/poisson_ratio":
		return soft_body_poisson_ratio
	if property == "mechanical/physics_object_properties/soft_body_properties/youngs_modulus":
		return soft_body_youngs_modulus
		
	if property == "mechanical/cutable":
		return cutable
		
	if property == "geometry/visual_mesh":
		return visual_mesh

func _set(property, value):
	if property == "mechanical/physics_object":
		physics_object = value
		property_list_changed_notify()
	if property == "mechanical/physics_object_properties/movable":
		movable = value
	if property == "mechanical/physics_object_properties/mass":
		mass = value
		
	if property == "mechanical/physics_object_properties/soft_body":
		soft_body = value
		property_list_changed_notify()
	if property == "mechanical/physics_object_properties/soft_body_properties/poisson_ratio":
		soft_body_poisson_ratio = value
	if property == "mechanical/physics_object_properties/soft_body_properties/youngs_modulus":
		soft_body_youngs_modulus = value
		
	if property == "mechanical/cutable":
		cutable = value
		
	if property == "geometry/visual_mesh":
		visual_mesh = value
		if get_child_count() == 0:
			var preview_visual_mesh = MeshInstance.new()
			preview_visual_mesh.mesh = visual_mesh
			add_child(preview_visual_mesh)
		else:
			$MeshInstance.mesh = visual_mesh
		
	return true



# call once when node selected 
func _get_property_list():
	var property_list = []
	
	property_list.append({
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string" : "Mesh", #Hint that the selection will only allow meshes
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
		"name": "geometry/visual_mesh",
		"type": TYPE_OBJECT
	})
	
	
	property_list.append({
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
		"name": "mechanical/cutable",
		"type": TYPE_BOOL
	})
	
	property_list.append({
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
		"name": "mechanical/physics_object",
		"type": TYPE_BOOL
	})

	if physics_object==true:
		property_list.append({
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
			"name": "mechanical/physics_object_properties/movable",
			"type": TYPE_BOOL
		})
		property_list.append({
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
			"name": "mechanical/physics_object_properties/mass",
			"type": TYPE_REAL
		})
		property_list.append({
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
			"name": "mechanical/physics_object_properties/soft_body",
			"type": TYPE_BOOL
		})
		if soft_body==true:
			property_list.append({
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
				"name": "mechanical/physics_object_properties/soft_body_properties/poisson_ratio",
				"type": TYPE_REAL
			})
			property_list.append({
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
				"name": "mechanical/physics_object_properties/soft_body_properties/youngs_modulus",
				"type": TYPE_REAL
			})
	return property_list

func get_path_to_visual_mesh():
	var project_path = ProjectSettings.globalize_path("res://")
	if get_child_count() != 0:
		var object_path = visual_mesh.resource_path # This line still throws an error, but it works
		var absolute_object_path = project_path + object_path.substr(6,-1)
		return absolute_object_path

func get_xml_tree():
	var xml_tree = XMLSceneTree.new()
	var r = xml_tree.get_root()
	r.add_property("name", self.name)
	r.add_child("EulerImplicitSolver").add_properties({"rayleighStiffness":"0.01", "rayleighMass":"0.1"})
	r.add_child("CGLinearSolver").add_properties({"iterations":25, "threshold":0.00000001, "tolerance":1e-05})
	r.add_child("MechanicalObject").add_properties({"template":"Rigid3d", "scale":1.0})
	r.add_child("UniformMass")
	
	if(not movable):
		r.add_child("FixedConstraint").add_properties({"name":"FixedConstraint", "fixAll":true})
	
	
	var vis = r.add_child("Node").add_properties({"name":"Visual"})
	#<MeshObjLoader name="meshVisualLoader" filename="mesh/torus.obj"/>
	#<OglModel name="Visual" src="@meshVisualLoader" color="gray" scale="1.0"/>
	#<RigidMapping input="@.." output="@Visual"/>
	vis.add_child("MeshObjLoader").add_properties({"name":"VisualMeshLoader", "filename":get_path_to_visual_mesh(), "scale3d":scale, "rotation":rotation_degrees, "translation":translation})
	vis.add_child("OglModel").add_properties({"name":"VisualModel", "src":"@VisualMeshLoader", "scale":1.0})
	vis.add_child("RigidMapping").add_properties({"input":"@..", "output":"@VisualModel"})
	
	var col = r.add_child("Node").add_properties({"name":"Collision"})
	col.add_child("MeshObjLoader").add_properties({"name":"CollisionMeshLoader", "filename":get_path_to_visual_mesh(), "scale3d":scale, "rotation":rotation_degrees, "translation":translation})
	col.add_child("MeshTopology").add_properties({"src":"@CollisionMeshLoader"})
	col.add_child("MechanicalObject").add_properties({"scale":1.0})
	return xml_tree

#func _enter_tree():
#	connect("pressed", self, "clicked")
