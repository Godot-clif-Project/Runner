#tool
extends Node

export var instances = 2
export var run_games = false setget run_games

func run_games(value):
	var editor_plugin = EditorPlugin.new()
	for i in instances:
		editor_plugin.get_editor_interface().play_custom_scene("res://stages/lobby.tscn")
#		EditorInterface.play_main_scene()
