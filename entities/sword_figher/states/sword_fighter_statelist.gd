extends Resource

const INITIAL_STATE = "offensive_stance"

const RESOURCE_COSTS = {
#	"state" : [sp, bullets, tension]
#	"cross_drive" : [100, 0, 0],
}

const STATES = {
	"offensive_stance" : preload("res://entities/sword_figher/states/sword_fighter_offensive_stance.gd"),
	"defensive_stance" : preload("res://entities/sword_figher/states/sword_fighter_defensive_stance.gd"),
	"off_hi_light" : preload("res://entities/sword_figher/states/sword_fighter_off_hi_light.gd"),
	"off_hi_heavy" : preload("res://entities/sword_figher/states/sword_fighter_off_hi_heavy.gd"),
	"off_hi_heavy_1" : preload("res://entities/sword_figher/states/sword_fighter_off_hi_heavy_1.gd"),
	"off_hi_fierce" : preload("res://entities/sword_figher/states/sword_fighter_off_hi_fierce.gd"),
	"off_kick" : preload("res://entities/sword_figher/states/sword_fighter_off_kick.gd"),
	"off_block" : preload("res://entities/sword_figher/states/sword_fighter_off_block.gd"),
	"off_throw_f" : preload("res://entities/sword_figher/states/sword_fighter_off_throw_f.gd"),
	"def_hi_light" : preload("res://entities/sword_figher/states/sword_fighter_def_hi_light.gd"),
	"stance_switch" : preload("res://entities/sword_figher/states/sword_fighter_stance_switch.gd"),
	"hit_stun" : preload("res://entities/sword_figher/states/sword_fighter_hit_stun.gd"),
	"run" : preload("res://entities/sword_figher/states/sword_fighter_run.gd"),
	"off_run_startup" : preload("res://entities/sword_figher/states/sword_fighter_run_startup.gd"),
	"run_stop" : preload("res://entities/sword_figher/states/sword_fighter_run_stop.gd"),
	"wall_run" : preload("res://entities/sword_figher/states/sword_fighter_wall_run.gd"),
	"wall_run_side" : preload("res://entities/sword_figher/states/sword_fighter_wall_run_side.gd"),
	"walk" : preload("res://entities/sword_figher/states/sword_fighter_walk.gd"),
	"jump" : preload("res://entities/sword_figher/states/sword_fighter_jump.gd"),
	"fall" : preload("res://entities/sword_figher/states/sword_fighter_fall.gd"),
	"land" : preload("res://entities/sword_figher/states/sword_fighter_land.gd"),
	"ledge_climb" : preload("res://entities/sword_figher/states/sword_fighter_ledge_climb.gd"),
	"def_step" : preload("res://entities/sword_figher/states/sword_fighter_def_step.gd"),
	"receive_throw" : preload("res://entities/sword_figher/states/sword_fighter_receive_throw.gd"),
	"guard_broken" : preload("res://entities/sword_figher/states/sword_fighter_guard_broken.gd"),
	"tandem_rope_pull" : preload("res://entities/sword_figher/states/sword_fighter_tandem_rope_pull.gd"),
	"tandem_rope_being_pulled" : preload("res://entities/sword_figher/states/sword_fighter_tandem_rope_being_pulled.gd"),
	"tandem_launch_up" : preload("res://entities/sword_figher/states/sword_fighter_tandem_launch_up.gd"),
	"air_boost" : preload("res://entities/sword_figher/states/sword_fighter_air_boost.gd"),
	"dangle" : preload("res://entities/sword_figher/states/sword_fighter_dangle.gd"),
	"slide" : preload("res://entities/sword_figher/states/sword_fighter_slide.gd"),
	}
