package main

import "core:fmt"
import rl "vendor:raylib"

/*
 If the level is finished move on to another level
*/


Level :: struct {
    name        : cstring,
	envs        : [dynamic]EnvItem,
	is_finished : bool,
	is_active   : bool,
}

//We assume that non of the levels are initilized here
init_levels :: proc(){
	assert(len(state.levels) == 0)
	init_level_1()
	init_level_2()
}

render_level_selector :: proc (){
	rl.BeginDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)
    x, y : f32 = 200, 200
    for &level, i in &state.levels{
        if rl.GuiButton(rl.Rectangle{x , y, 90, 90}, level.name){
            fmt.println("Clicked")
            state.mode = .PLAY
            state.curr_level =  u32(i)
        }
        if level.is_finished{
            rl.DrawRectangleLines(i32(x), i32(y), 90, 90, rl.RED)
        }
        x += 100
    }
	rl.EndDrawing()
}

init_level_1 :: proc(){
	append_nothing(&state.levels)
	level := &state.levels[0]
	window_size := state.window_size
    level.name = "Level 1"
	using level


	append(&envs, create_env_item({-window_size.x/2.0,   0,   300, 100}))
	append(&envs, create_env_item({-window_size.x/2.0,   window_size.y/2-50,   850, 50}))
	append(&envs, create_env_item({-window_size.x/2.0,   -window_size.y/2,   850, 50}))
	append(&envs, create_env_item({-window_size.x/2.0,   -window_size.y/2,   50, 850}))
	append(&envs, create_env_item({window_size.x/2.0-50,   -window_size.y/2,   50, 850}))
	append(&envs, create_env_item({0,   0,   100, 100}))
	append(&envs, create_env_item({275,   -300,   100, 10}, true))
	append(&envs, create_env_item({200,   0,   100, 100}))
	is_finished = false
}

init_level_2 :: proc(){
    append_nothing(&state.levels)
	level := &state.levels[1]
    level.name = "Level 2"
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
