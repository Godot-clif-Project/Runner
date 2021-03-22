extends Spatial

onready var audio_streams = [
	$AudioStreamPlayer3D,
	$AudioStreamPlayer3D2,
	$AudioStreamPlayer3D3,
	$AudioStreamPlayer3D4,
	$AudioStreamPlayer3D5
	]

func play(sound_name : String):
	if not audio_streams.empty():
		if sound_name == "step":
			audio_streams[0].stream = $ResourcePreloader.get_resource("step-0" + str(randi() % 7 + 1))
	#		audio_streams[0].unit_db = 20 * (horizontal_speed / (MAX_SPEED * 0.5)) 
		else:
			audio_streams[0].stream = $ResourcePreloader.get_resource(sound_name)
			
		audio_streams[0].play()
		audio_streams.pop_front()
		
	elif sound_name != "step":
		$AudioStreamPlayer3D.stream = $ResourcePreloader.get_resource(sound_name)
		$AudioStreamPlayer3D.play()
	
			
#	$AudioStreamPlayer3D.stream = $ResourcePreloader.get_resource("step-0" + str(randi() % 5 + 1))
#	$AudioStreamPlayer3D.play()

func _on_AudioStreamPlayer3D_finished():
	audio_streams.append($AudioStreamPlayer3D)

func _on_AudioStreamPlayer3D2_finished():
	audio_streams.append($AudioStreamPlayer3D2)

func _on_AudioStreamPlayer3D3_finished():
	audio_streams.append($AudioStreamPlayer3D3)

func _on_AudioStreamPlayer3D4_finished():
	audio_streams.append($AudioStreamPlayer3D4)

func _on_AudioStreamPlayer3D5_finished():
	audio_streams.append($AudioStreamPlayer3D5)
