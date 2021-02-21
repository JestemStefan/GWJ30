extends Control

var mainMenu : PackedScene = load("res://levels/MainMenu.tscn")


func _ready():
	$ColorRect/AnimationPlayer.play("Transition")


func _on_AnimationPlayer_animation_finished(anim_name):	
	get_tree().change_scene_to(mainMenu)


func _on_TextureRect_visibility_changed():
	if $TextureRect.visible == true:
		$AudioStreamPlayer.play()
