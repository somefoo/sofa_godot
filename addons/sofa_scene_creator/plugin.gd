tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SofaObject", "Spatial", preload("sofa_object.gd"), preload("icons/sofa_object_icon.png"))
	add_custom_type("SofaRoot", "Node", preload("sofa_root.gd"), preload("icons/sofa_root_icon.png"))
	add_custom_type("SofaAABoxROI", "Spatial", preload("sofa_aa_box_roi.gd"), preload("icons/sofa_aa_box_roi_icon.png"))
	add_custom_type("SofaSphereROI", "Spatial", preload("sofa_sphere_roi.gd"), preload("icons/sofa_aa_sphere_roi_icon.png"))
	#add_custom_type("SofaPointConstraintTarget", "Spatial", preload("sofa_point_constraint_target.gd"), preload("icons/sofa_point_constraint_target_icon.png"))
	add_custom_type("SofaFixedConstraint", "Spatial", preload("sofa_fixed_constraint.gd"), preload("icons/sofa_fixed_constraint_icon.png"))
	add_custom_type("SofaAttachConstraint", "Spatial", preload("sofa_attach_constraint.gd"), preload("icons/sofa_attach_constraint_icon.png"))
	add_custom_type("SofaBilateralInteractionConstraint", "Spatial", preload("sofa_bilateral_interaction_constraint.gd"), preload("icons/sofa_bilateral_interaction_constraint_icon.png"))
	add_custom_type("SofaBoxConstraint", "Spatial", preload("sofa_box_constraint.gd"), preload("icons/sofa_point_constraint_target_icon.png"))
	add_custom_type("SofaFixedPlaneConstraint", "Spatial", preload("sofa_fixed_plane_constraint.gd"), preload("icons/sofa_fixed_plane_constraint_icon.png"))
	add_custom_type("SofaSlidingConstraint", "Spatial", preload("sofa_sliding_constraint.gd"), preload("icons/sofa_sliding_constraint_icon.png"))
	add_custom_type("SofaCamera", "Camera", preload("sofa_camera.gd"), preload("icons/sofa_camera_icon.png"))
	add_custom_type("SofaVisualGrid", "Spatial", preload("sofa_visual_grid.gd"), preload("icons/sofa_visual_grid_icon.png"))
	add_custom_type("SofaPointlight", "OmniLight", preload("sofa_pointlight.gd"), preload("icons/sofa_pointlight_icon.png"))
	pass


func _exit_tree():
	remove_custom_type("SofaRoot")
	remove_custom_type("SofaObject")
	remove_custom_type("SofaAABoxROI")
	remove_custom_type("SofaSphereROI")
	remove_custom_type("SofaFixedConstraint")
	#remove_custom_type("SofaPointConstraintTarget")
	remove_custom_type("SofaAttachConstraint")
	remove_custom_type("SofaBilateralInteractionConstraint")
	remove_custom_type("SofaBoxConstraint")
	remove_custom_type("SofaFixedPlaneConstraint")
	remove_custom_type("SofaSlidingConstraint")
	remove_custom_type("SofaCamera")
	remove_custom_type("SofaVisualGrid")
	remove_custom_type("SofaPointlight")
	pass
