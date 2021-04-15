tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SofaObject", "Spatial", preload("sofa_object.gd"), preload("icons/sofa_object_icon.png"))
	add_custom_type("SofaRoot", "Node", preload("sofa_root.gd"), preload("icons/sofa_root_icon.png"))
	add_custom_type("SofaAABoxROI", "Spatial", preload("sofa_aa_box_roi.gd"), preload("icons/sofa_aa_box_roi_icon.png"))
	pass


func _exit_tree():
	remove_custom_type("SofaRoot")
	remove_custom_type("SofaObject")
	remove_custom_type("SofaAABoxROI")
	pass
