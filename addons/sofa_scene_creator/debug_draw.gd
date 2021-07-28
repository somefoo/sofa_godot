tool
extends ImmediateGeometry

var material = SpatialMaterial.new()
var lines = []

class Line:
	func _init(p0, p1, color):
		self.p0 = p0
		self.p1 = p1
		self.color = color
	var p0
	var p1
	var color

func draw_line(p0, p1, color : Color = Color(1,0,0,1)):
	lines.push_back(Line.new(p0, p1, color))
func draw_line_world_space(object, p0, p1, color : Color = Color(1,0,0,1)):
	lines.push_back(Line.new(p0 - object.get_global_transform().origin, p1 - object.get_global_transform().origin, color))

func _enter_tree():
	if Engine.is_editor_hint():
		set_process(true)
		material.flags_use_point_size = true
		material.vertex_color_use_as_albedo = true
		material.flags_unshaded = true
		material.flags_transparent = true
		
		
func _process(delta):
	if Engine.is_editor_hint():
		
		clear()
		for l in lines:
			set_material_override(material)
			begin(Mesh.PRIMITIVE_POINTS, null)
			add_vertex(l.p0)
			add_vertex(l.p1)
			end()
			begin(Mesh.PRIMITIVE_LINE_STRIP, null)
			set_color(l.color)
			add_vertex(l.p0)
			add_vertex(l.p1)
			end()
	lines.clear()


#var begin = Vector3()
#var end = Vector3()
#var begin_path
#var end_path
#var m = SpatialMaterial.new()
#
#onready var start_node = Spatial.new()
#onready var end_node = Spatial.new()
#
#var path = []
#var draw_path = true
#
#export(NodePath) var draw_start setget set_draw_start, get_draw_start
#export(NodePath) var draw_end setget set_draw_end, get_draw_end
#
#
#func set_draw_start(val):
#	if Engine.is_editor_hint():
#		begin_path = val
#		start_node = get_node(val)
#		draw_path_tool( \
#			start_node.get_transform().origin - start_node.get_transform().origin, \
#			end_node.get_transform().origin - start_node.get_transform().origin)
#	else:
#		pass
#
#
#func set_draw_end(val):
#	if Engine.is_editor_hint():
#		end_path = val
#		end_node = get_node(val)
#		draw_path_tool( \
#			start_node.get_transform().origin - start_node.get_transform().origin, \
#			end_node.get_transform().origin - start_node.get_transform().origin)
#	else:
#		pass
#
#
#func get_draw_start():
#	return begin_path
#
#
#func get_draw_end():
#	return end_path
#
#
#func _ready():
#	if Engine.is_editor_hint():
#		draw_path_tool(start_node.get_transform().origin, end_node.get_transform().origin)
#		set_process(true)
#		m.flags_unshaded = true
#		m.flags_use_point_size = true
#		m.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
#
#		if get_tree().get_root().has_node("start"):
#			print('ok')
#		else:
#			print('nok')
#		if get_tree().get_root().has_node("end"):
#			print('ok')
#		else:
#			print('nok')
#
#func _process(delta):
#	if Engine.is_editor_hint():
#		draw_path_tool(start_node.get_transform().origin, end_node.get_transform().origin)
#
#
#
#
#
#
#func draw_path_tool(_start_pos, _end_pos):
#	var p = Array()
#	p.append(_start_pos)
#	p.append(_end_pos)
#	path.invert()
#
#	if (draw_path):
#		set_material_override(m)
#		clear()
#		begin(Mesh.PRIMITIVE_POINTS, null)
#		add_vertex(_start_pos)
#		add_vertex(_end_pos)
#		end()
#		begin(Mesh.PRIMITIVE_LINE_STRIP, null)
#		for x in p:
#			add_vertex(x)
#		end()
