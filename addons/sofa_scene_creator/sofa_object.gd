tool
extends Spatial


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
	var preview_visual_mesh = MeshInstance.new()
	preview_visual_mesh.mesh = visual_mesh
	add_child(preview_visual_mesh)
	
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
		var project_path = ProjectSettings.globalize_path("res://")
		if get_child_count() != 0:
			var object_path = $MeshInstance.get_mesh().resource_path # This line still throws an error, but it works
			var absolute_object_path = project_path + object_path.substr(6,-1)
			print("Set visual mesh to: " + absolute_object_path)
			visual_mesh = value
			$MeshInstance.mesh = visual_mesh
			property_list_changed_notify()
		
	return true

# call once when node selected 
func _get_property_list():
	var property_list = []
	
	property_list.append({
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string" : "Mesh", #Hint that the selection will only allow meshes
		"usage": PROPERTY_USAGE_DEFAULT,
		"name": "geometry/visual_mesh",
		"type": TYPE_OBJECT
	})
	
	
	property_list.append({
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
		"name": "mechanical/cutable",
		"type": TYPE_BOOL
	})
	
	property_list.append({
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
		"name": "mechanical/physics_object",
		"type": TYPE_BOOL
	})

	if physics_object==true:
		property_list.append({
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "mechanical/physics_object_properties/movable",
			"type": TYPE_BOOL
		})
		property_list.append({
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "mechanical/physics_object_properties/mass",
			"type": TYPE_REAL
		})
		property_list.append({
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,
			"name": "mechanical/physics_object_properties/soft_body",
			"type": TYPE_BOOL
		})
		if soft_body==true:
			property_list.append({
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
				"name": "mechanical/physics_object_properties/soft_body_properties/poisson_ratio",
				"type": TYPE_REAL
			})
			property_list.append({
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
				"name": "mechanical/physics_object_properties/soft_body_properties/youngs_modulus",
				"type": TYPE_REAL
			})
	return property_list



#func _enter_tree():
#	connect("pressed", self, "clicked")
