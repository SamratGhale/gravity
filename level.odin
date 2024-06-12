package main

/*
 If the level is finished move on to another level
*/


Level :: struct {
	envs        : [dynamic]EnvItem,
	is_finished : bool,
	is_active   : bool,
}

//We assume that non of the levels are initilized here
init_levels :: proc(){
	assert(len(state.levels) == 0)

	append_nothing(&state.levels)
	init_level_1()
}

init_level_1 :: proc(){
	level := &state.levels[0]
	window_size := state.window_size
	using level


	append(&envs, create_env_item({-window_size.x/2.0,   0,   300, 100}))
	append(&envs, create_env_item({-window_size.x/2.0,   window_size.y/2-50,   850, 50}))
	append(&envs, create_env_item({-window_size.x/2.0,   -window_size.y/2,   850, 50}))

	append(&envs, create_env_item({-window_size.x/2.0,   -window_size.y/2,   50, 850}))
	append(&envs, create_env_item({window_size.x/2.0-50,   -window_size.y/2,   50, 850}))
	append(&envs, create_env_item({0,   0,   100, 100}))
	append(&envs, create_env_item({300,   300,   100, 100}, true))
	append(&envs, create_env_item({200,   0,   100, 100}))
	is_finished = false
}