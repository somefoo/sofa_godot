tool
extends Spatial
const XMLSceneTree = preload("res://addons/sofa_scene_creator/xml_scene_tree.gd")

#export(Array, NodePath) var fixed_constraints
#export(Array, NodePath) var bidirectional_attach_constraints

var physics_object : bool = true
var movable : bool = true
var mass : float = 1.0

var soft_body : bool = false
var soft_body_poisson_ratio : float = 0.4
var soft_body_youngs_modulus : float = 10000.0
#var gmsh_file = ""

var rigid_body_is_carving_tool : bool = false

var soft_body_carving_surface : bool = false

var visual_mesh : Mesh = CubeMesh.new()
var visual_color : Color = Color(0.5, 0.5, 0.5, 1)
var visual_texture : String = "None"
var material = SpatialMaterial.new()
#onready var meshInstance = $Mesh
#export (SpatialMaterial) var material = SpatialMaterial.new()

func _enter_tree():
	#var preview_visual_mesh = MeshInstance.new()
	#preview_visual_mesh.mesh = visual_mesh
	#add_child(preview_visual_mesh)
	
	print("Sofa Object Entered Tree.")

# See GODOT reference https://docs.godotengine.org/en/stable/classes/class_object.html
func _get(property):
	if property == "scale":
		return scale
	if property == "rotation_degrees":
		return rotation_degrees
	if property == "translation":
		return translation
	
	
	if property == "mechanical/physics_object":
		return physics_object
	if property == "mechanical/physics_object_properties/movable":
		return movable
	if property == "mechanical/physics_object_properties/mass":
		return mass
		
	if property == "mechanical/physics_object_properties/soft_body":
		return soft_body
	#if property == "mechanical/physics_object_properties/soft_body_properties/gmsh_file":
	#	return gmsh_file
	if property == "mechanical/physics_object_properties/soft_body_properties/poisson_ratio":
		return soft_body_poisson_ratio
	if property == "mechanical/physics_object_properties/soft_body_properties/youngs_modulus":
		return soft_body_youngs_modulus
	
	if property == "mechanical/physics_object_properties/rigid_body_properties/carving_tool":
		return rigid_body_is_carving_tool
		
	if property == "mechanical/physics_object_properties/soft_body_properties/carving_surface":
		return soft_body_carving_surface
		
	if property == "geometry/visual_mesh":
		return visual_mesh
	if property == "visual/color":
		return visual_color
	if property == "visual/texture":
		return visual_texture

# See GODOT reference https://docs.godotengine.org/en/stable/classes/class_object.html
func _set(property, value):
	print("set: ", property, " ", value)
	
	if property == "scale":
		scale = value
	if property == "rotation_degrees":
		rotation_degrees = value
	if property == "translation":
		translation = value
	
	
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
	#if property == "mechanical/physics_object_properties/soft_body_properties/gmsh_file":
	#	gmsh_file = value
	if property == "mechanical/physics_object_properties/rigid_body_properties/carving_tool":
		rigid_body_is_carving_tool = value
		
	if property == "mechanical/physics_object_properties/soft_body_properties/carving_surface":
		soft_body_carving_surface = value
		
	if property == "geometry/visual_mesh":
		visual_mesh = value
		if get_node_or_null("MeshInstance") == null:
			var preview_visual_mesh = MeshInstance.new()
			preview_visual_mesh.mesh = visual_mesh
			#preview_visual_mesh.set_surface_material(0, material)
			preview_visual_mesh.set_surface_material(0, material)
			add_child(preview_visual_mesh)
			
			
		#if get_child_count() == 0:
		#	var preview_visual_mesh = MeshInstance.new()
		#	preview_visual_mesh.mesh = visual_mesh
		#	add_child(preview_visual_mesh)
		else:
			$MeshInstance.mesh = visual_mesh
			$MeshInstance.set_surface_material(0, material)
		property_list_changed_notify()
	if property == "visual/color":
		visual_color = value
		if get_node_or_null("MeshInstance") == null:
			pass
		else:
			var material = $MeshInstance.get_surface_material(0)
			material.albedo_color = visual_color
	if property == "visual/texture":
		var checkFile = File.new()
		if checkFile.file_exists(value) or value == "" or value == "None" or value == "none" or value == "null" or value == "Null":
			if(value == ""):
				visual_texture = "None"
			else:
				visual_texture = value
		else:
			return false
		
		if get_node_or_null("MeshInstance") == null or visual_texture == "None":
			pass
		else:
			material.albedo_texture = load(value)
		
	return true

# See GODOT reference https://docs.godotengine.org/en/stable/classes/class_object.html
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
			#property_list.append({
			#	"hint": PROPERTY_HINT_FILE,
			#	"hint_string" : "*.gmsh, *.msh",
			#	"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
			#	"name": "mechanical/physics_object_properties/soft_body_properties/gmsh_file",
			#	"type": TYPE_STRING
			#})
			property_list.append({
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
				"name": "mechanical/physics_object_properties/soft_body_properties/carving_surface",
				"type": TYPE_BOOL
			})
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
		else:
			property_list.append({
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
				"name": "mechanical/physics_object_properties/rigid_body_properties/carving_tool",
				"type": TYPE_BOOL
			})
			
	property_list.append({
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
		"name": "visual/color",
		"type": TYPE_COLOR
	})
	
	property_list.append({
		"hint": PROPERTY_HINT_FILE,
		"hint_string" : "*.jpg, *.png",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
		"name": "visual/texture",
		"type": TYPE_STRING
	})
	return property_list

# Returns the path to the visual (.jpg, .png) texture-file of this object
func get_path_to_visual_texture():
	var project_path = ProjectSettings.globalize_path("res://")
	if get_child_count() != 0:
		var object_path = visual_texture # This line still throws an error, but it works
		var absolute_object_path = project_path + object_path.substr(6,-1)
		return absolute_object_path


# Returns the path to the visual (.obj) mesh-file of this object
func get_path_to_visual_mesh():
	var project_path = ProjectSettings.globalize_path("res://")
	if get_child_count() != 0:
		var object_path = visual_mesh.resource_path # This line still throws an error, but it works
		var absolute_object_path = project_path + object_path.substr(6,-1)
		return absolute_object_path

# Returns the path to the gmsh (.msh) mesh-file of this object
func get_path_to_gmsh_mesh():
	var path = get_path_to_visual_mesh()
	return path.substr(0, len(path) -4) + '.msh'

# Creates gmsh files from .obj visual mesh and stores it in the same folder
func generate_gmsh_mesh():
	var path = get_path_to_visual_mesh()
	var export_path = get_path_to_gmsh_mesh()
	
	var date_test = File.new()
	
	if(date_test.file_exists(export_path)):
		if(date_test.get_modified_time(path) < date_test.get_modified_time(export_path)):
			print("Skipped Gmsh-Conversion (already newest)")
			return
	
	var tmp_file = "/tmp/generated_gmsh_tmp.geo"
	var tmp_3d_file = "/tmp/generated_stl.stl"
	
	if(path.substr(len(path) -4, -1) == ".obj"):
		
		
		var ctmconv_binary = File.new()
		if(ctmconv_binary.file_exists(get_tree().root.get_child(0).ctmconv_binary_path)):
			var output = []
			#Blocking call:
			var pid = OS.execute(get_tree().root.get_child(0).ctmconv_binary_path, [path, tmp_3d_file], true, output)
			if(get_tree().root.get_child(0).print_gmsh_output):
				print("########## CTMCONV OUTPUT BEGIN ##########")
				for line in output:
					print(line)
				print("########## CTMCONV OUTPUT END   ##########")

		else:
			print("ctmconv path not set correctly, meshes cannot be generated.")
			print("  Set the ctmconv binary path in the root node.")
			print("  [sudo apt install openctm-tools]")
		
		var file = File.new()
		file.open(tmp_file, File.WRITE)
		var geo_string = ""
		geo_string += "Merge " + '"' + tmp_3d_file + '"' + ";\n"
		geo_string += 'Surface Loop(1) = {1};\n'
		geo_string += 'Volume(1) = {1};\n'
		file.store_string(geo_string)
		file.close()
		
		
		var gmsh_binary = File.new()
		if(gmsh_binary.file_exists(get_tree().root.get_child(0).gmsh_binary_path)):
			var output = []
			#Blocking call:
			var pid = OS.execute(get_tree().root.get_child(0).gmsh_binary_path, [tmp_file, '-3', '-o', export_path, '-format', '"msh22"'], true, output)
			if(get_tree().root.get_child(0).print_gmsh_output):
				print("########## GMSH OUTPUT BEGIN ##########")
				for line in output:
					print(line)
				print("########## GMSH OUTPUT END   ##########")

		else:
			print("Gmsh path not set correctly, meshes cannot be generated.")
			print("  Set the gmsh binary path in the root node.")
			print("  [sudo apt install gmsh]")



# Attach nodes for rigid-bodies (also edit rigid-body if you edit this)
func add_rigid_body_subtree(r):
	#TODO Still not working, IdentityMapping is the issue
	r.add_child("EulerImplicitSolver").add_properties({"rayleighStiffness":"0.01", "rayleighMass":"0.1"})
	r.add_child("CGLinearSolver").add_properties({"iterations":25, "threshold":1.0e-9, "tolerance":1.0e-9})
	
	r.add_child("MeshObjLoader").add_properties({"name":"loader", "filename":get_path_to_visual_mesh(), "scale3d":scale})
	#r.add_child("MeshObjLoader").add_properties({"name":"loader", "filename":get_path_to_visual_mesh()})
	
	#r.add_child("MechanicalObject").add_properties({"name":"dofs","src":"@loader","template":"Vec3d"})
	r.add_child("MechanicalObject").add_properties({"name":"dofs","template":"Rigid3d","rotation":rotation_degrees, "translation":translation})
	r.add_child("UniformMass").add_properties({"totalMass":mass})
	#r.add_child("DiagonalMass").add_properties({"totalMass":mass})
	r.add_child("UncoupledConstraintCorrection")
	
	if(not movable):
		# This could also be done using the simulated/moving tags of the collider
		r.add_child("FixedConstraint").add_properties({"name":"FixedConstraint", "fixAll":true})
	
	
	var vis = r.add_child("Node").add_properties({"name":"Visual"})
	#<MeshObjLoader name="meshVisualLoader" filename="mesh/torus.obj"/>
	#<OglModel name="Visual" src="@meshVisualLoader" color="gray" scale="1.0"/>
	#<RigidMapping input="@.." output="@Visual"/>
	#vis.add_child("MeshObjLoader").add_properties({"name":"VisualMeshLoader", "filename":get_path_to_visual_mesh(), "scale3d":scale, "rotation":rotation_degrees, "translation":translation})
	if(visual_texture != "None"):
		vis.add_child("OglModel").add_properties({"name":"VisualModel", "filename":get_path_to_visual_mesh(), "color":visual_color, "texturename":get_path_to_visual_texture(), "scale3d":scale})
	else:
		vis.add_child("OglModel").add_properties({"name":"VisualModel", "filename":get_path_to_visual_mesh(), "color":visual_color, "scale3d":scale})
	#vis.add_child("IdentityMapping").add_properties({"input":"@../dofs", "output":"@VisualModel"})
	vis.add_child("RigidMapping").add_properties({"input":"@../dofs", "output":"@VisualModel", "applyRestPosition":"True"})
	
	var col = r.add_child("Node").add_properties({"name":"Collision"})
	#col.add_child("MeshObjLoader").add_properties({"name":"CollisionMeshLoader", "filename":get_path_to_visual_mesh(), "scale3d":scale, "rotation":rotation_degrees, "translation":translation})
	col.add_child("MeshTopology").add_properties({"src":"@../loader"})
	col.add_child("MechanicalObject").add_properties({"name":"dofsc", "src":"@../loader"})
	
	
	var tags = ""
	if rigid_body_is_carving_tool == true:
		tags = "CarvingTool"
	
	col.add_child("TriangleCollisionModel").add_properties({"contactStiffness":10, "tags":tags})
	col.add_child("LineCollisionModel").add_properties({"contactStiffness":10, "tags":tags})
	col.add_child("PointCollisionModel").add_properties({"contactStiffness":10, "tags":tags})
	#col.add_child("IdentityMapping").add_properties({"input":"@../dofs", "output":"@dofsc"})
	col.add_child("RigidMapping")
# Attach nodes for soft-bodies (also edit soft-body if you edit this)
func add_soft_body_subtree(r):
	# Generate gmsh file if the current visual mesh is newer than the gmsh
	generate_gmsh_mesh()
	
	
	
	
	r.add_child("EulerImplicitSolver").add_properties({"printLog":"false", "rayleighStiffness":0.1, "rayleighMass":0.1})
	r.add_child("CGLinearSolver").add_properties({"iterations":"150","tolerance":1.0e-9,"threshold":1.0e-9}) # We need a lot of iterations, otherwise the size of the uniform-mass affects the scene too much
	#r.add_child("SparseLDLSolver")
	#r.add_child("ShewchukPCGLinearSolver").add_properties({"iterations":"1000", "tolerance":'1e-9', "preconditioners":"LUSolver", "build_precond":'1', "update_step":'1000'})
	r.add_child("MeshGmshLoader").add_properties({"filename":get_path_to_gmsh_mesh(),"name":"loader", "scale3d":scale, "rotation":rotation_degrees, "translation":translation})
	r.add_child("MechanicalObject").add_properties({"src":"@loader","name":"dofs"})
#
#	# addTetrahedronSetTopology
	r.add_child("TetrahedronSetTopologyContainer").add_properties({"name":"Container","src":"@loader","tags":" "})
	r.add_child("TetrahedronSetTopologyModifier").add_properties({"name":"Modifier"})
	r.add_child("TetrahedronSetGeometryAlgorithms").add_properties({"name":"GeomAlgo","template":"Vec3d"})

	#r.add_child("UniformMass").add_properties({"totalMass":mass}) # This causes a crashes when used with carving, use DiagonalMass
	r.add_child("DiagonalMass").add_properties({"totalMass":mass})
	r.add_child("TetrahedronFEMForceField").add_properties({"youngModulus":soft_body_youngs_modulus,"poissonRatio":soft_body_poisson_ratio,"method":"large"})
	r.add_child("UncoupledConstraintCorrection").add_properties({"useOdeSolverIntegrationFactors":1})


	var t = r.add_child("Node").add_properties({"name":"Topo"})
	# addTriangleSetTopology
	t.add_child("TriangleSetTopologyContainer").add_properties({"name":"Container","src":"@","fileTopology":"","tags":""})
	t.add_child("TriangleSetTopologyModifier").add_properties({"name":"Modifier"})
	t.add_child("TriangleSetGeometryAlgorithms").add_properties({"name":"GeomAlgo","template":"Vec3d"})
	t.add_child("Tetra2TriangleTopologicalMapping").add_properties({"input":"@../Container","output":"@Container"})
	
	if(soft_body_carving_surface):
		t.add_child("TriangleCollisionModel").add_properties({"tags":"CarvingSurface"})
	else:
		t.add_child("TriangleCollisionModel")

	var v = t.add_child("Node").add_properties({"name":"Visual"})
	if(visual_texture != "None"):
		v.add_child("OglModel").add_properties({"name":"VisualModel","color":visual_color,"texturename":get_path_to_visual_texture()})
	else:
		v.add_child("OglModel").add_properties({"name":"VisualModel","color":visual_color})
	v.add_child("IdentityMapping").add_properties({"input":"@../../dofs","output":"@VisualModel"})

func get_xml_tree():
	var xml_tree = XMLSceneTree.new()
	var r = xml_tree.get_root()
	r.add_property("name", self.name)
	#r.add_child("EulerImplicitSolver").add_properties({"rayleighStiffness":"0.01", "rayleighMass":"0.1"})
	#r.add_child("CGLinearSolver").add_properties({"iterations":25, "threshold":0.00000001, "tolerance":1e-05})
	
	if(soft_body):
		add_soft_body_subtree(r)
	else:
		add_rigid_body_subtree(r)
	return xml_tree

#func _enter_tree():
#	connect("pressed", self, "clicked")
