package main
import rl "vendor:raylib"
import fmt "core:fmt"
import "core:math/linalg"

render_game :: proc(){
	using state
	delta_time :f32= rl.GetFrameTime()


	camera.zoom += rl.GetMouseWheelMove() * 0.05


	if (camera.zoom > 3.0) do camera.zoom = 3.0;
	else if (camera.zoom < 0.25) do camera.zoom = 0.25;

	if rl.IsKeyPressed(.R){
		player.orient = .Right
	}
	rl.BeginDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)

	rl.BeginMode2D(camera)
	{
		delta := delta_time * PLAYER_HOR_SPD
		player_ddp : vec2
		v := &player

		if(!v.is_falling){

			if rl.IsKeyPressed(.SPACE){
				if(!v.is_jumping){
					v.is_jumping = true
					v.jmp_index = 0
				}
			}
		}
		if(rl.IsKeyDown(.A)){
			if(v.orient == .Top){
				player_ddp.x -= delta
			}
			if(v.orient == .Right){
				player_ddp.y -= delta
			}
			if(v.orient == .Left){
				player_ddp.y += delta
			}
			if(v.orient == .Buttom){
				player_ddp.x += delta
			}
		}
		if(rl.IsKeyDown(.D)){
			if(v.orient == .Top){
				player_ddp.x += delta
			}
			if(v.orient == .Right){
				player_ddp.y += delta
			}
			if(v.orient == .Left){
				player_ddp.y -= delta
			}
			if(v.orient == .Buttom){
				player_ddp.x -= delta
			}
		}

		if(v.is_jumping){
			if(v.jmp_index > 30){
				v.is_jumping = false
				v.is_falling = true;
				v.jmp_index = 0;
			}
			switch(v.orient){
				case .Buttom:{
					player_ddp.y +=delta 
				}
				case .Top:{
					player_ddp.y -=  delta 
				}
				case .Left:{
					player_ddp.x -=delta 
				}
				case .Right:{
					player_ddp.x += delta
				}
			}
			v.jmp_index += 1;
		}else{
			if(v.is_falling){
				switch(v.orient){
					case .Buttom:{
						player_ddp.y -= delta
					}
					case .Top:{
						player_ddp.y += delta
					}
					case .Left:{
						player_ddp.x += delta
					}
					case .Right:{
						player_ddp.x -= delta
					}
				}
			}
		}
		spec : MoveSpec
		spec.speed = 200.0
		spec.drag  = 5.0
		move_player(&state, v, player_ddp, delta_time, spec)


	}


	level := levels[curr_level]
	for &item in &level.envs do rl.DrawRectangleRec(item.rect, item.color)


	player_rect := rl.Rectangle{player.pos.x - 20, player.pos.y - 40, 40, 40}


	rotation: f32
	offset : vec2

	switch(player.orient){
		case .Top:{
			rotation = 0.0
			offset = {f32(-player_idle.texs[0].width)/2 , f32(-player_idle.texs[0].height)}
		}
		case .Buttom:{
			rotation = 180.0
			offset = {f32(player_idle.texs[0].width)/2, f32(player_idle.texs[0].height)}
		}
		case .Left:{
			rotation = 270.0
			offset = {f32(-player_idle.texs[0].height), f32(player_idle.texs[0].width)/2}
		}
		case .Right:{
			rotation = 90.0
			offset = {f32(player_idle.texs[0].height), f32(-player_idle.texs[0].width)/2}
		}
	}
	camera.rotation = -rotation

	if player_prev_pos == player.pos || player_prev_pos == {0,0} {
		player_idle.stride += 1
		if player_idle.stride >= 14{
			player_idle.index += 1
			player_idle.stride = 0
		}

		if(int(player_idle.index) >= len(player_idle.texs)){
			player_idle.index  = 0
			player_idle.stride = 0
		}
		rl.DrawTextureEx(player_idle.texs[player_idle.index], player.pos + offset, rotation, 1, rl.WHITE)

	}else{
		anim := &player_walk[player.face_direction]

		anim.stride += 1
		if anim.stride >= 7{
			anim.index += 1
			anim.stride = 0
		}

		if(int(anim.index) >= len(anim.texs)){
			anim.index  = 0
			anim.stride = 0
		}

		tex := anim.texs[anim.index]
		rl.DrawTextureEx(anim.texs[anim.index], player.pos + offset,   rotation, 1, rl.WHITE)
	}


	rl.DrawCircle(i32(player.pos.x), i32(player.pos.y), 5, rl.GOLD)



	angel.stride += 1
	if angel.stride >= 7{
		angel.index += 1
		angel.stride = 0
	}

	if(int(angel.index) >= len(angel.texs)){
		angel.index  = 0
		angel.stride = 0
	}

	rl.DrawTextureEx(angel.texs[angel.index], {100, 10}, 0, 0.5 , rl.WHITE)
	rl.EndMode2D()
	rl.GuiStatusBar({2,2,200,30}, fmt.ctprintf("%f",player.pos))
	rl.GuiStatusBar({2,31,200,30}, fmt.ctprintf("%f",camera.offset))
	rl.GuiStatusBar({2,61,200,30}, fmt.ctprintf("Level %d",state.curr_level + 1))
	rl.GuiStatusBar({2,91,200,30}, fmt.ctprintf("Orient %s",state.player.orient))


	rl.EndDrawing()
	player_prev_pos = player.pos

}
