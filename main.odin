package main

import rl "vendor:raylib"
import fmt "core:fmt"
import "core:math/linalg"

G :: 400
PLAYER_JUMP_SPD :: 350
PLAYER_HOR_SPD  :: 200

FaceDirection :: enum{
	LEFT,
	RIGHT,
}

vec2 :: rl.Vector2

EntityBase :: struct {
	pos : vec2,
	scale : vec2,
	collides : b32,
	is_gravity : b32,
}

Orientation :: enum{
	Top, Left, Right, Buttom
}

Player :: struct{
	//pos     : rl.Vector2,
	using base : EntityBase,
	speed   : f32,
	orient  : Orientation,
	dp : vec2,
	canJump : bool,
	is_jumping: bool,
	is_falling: bool,
	jmp_index : i32,

	face_direction : FaceDirection,
}

Anim :: struct {
	texs   : [dynamic]rl.Texture,
	index  : u32,
	stride : u32,
}

EnvItem :: struct{
	using base : EntityBase,
	rect     : rl.Rectangle,
	color    : rl.Color,
	is_finish : bool, //this means that if the player touches this then the level is over
}



GameState :: struct{
	player      : Player,
	envs        : [dynamic]EnvItem,
	window_size : rl.Vector2,
	camera      : rl.Camera2D,
	angel       : Anim,

	player_walk : [FaceDirection]Anim,
	player_idle : Anim,
}

state : GameState

update_player :: proc(using state : ^GameState, delta : f32){
	if rl.IsKeyDown(.A)  {
		player.pos.x -= PLAYER_HOR_SPD * delta
		player.face_direction = .LEFT
	}
	if rl.IsKeyDown(.D) {
		player.pos.x += PLAYER_HOR_SPD * delta
		player.face_direction = .RIGHT
	}

	if rl.IsKeyDown(.SPACE) && player.canJump{
		player.speed   = -PLAYER_JUMP_SPD
		player.canJump = false
	}

	hit := false

	for &item in &envs{
		pos := &player.pos

		if (item.collides && (item.rect.x <= pos.x) && ((item.rect.x + item.rect.width) >= pos.x) && (item.rect.y >= pos.y) &&
		(item.rect.y <= pos.y + player.speed*delta)) {
			hit = true
			player.speed = 0
			pos.y = item.rect.y
			break
		}
	}

	if !hit{
		player.pos.y += player.speed * delta
		player.speed += G*delta
		player.canJump = false
	}else{
		player.canJump = true
	}
}

update_camera_center :: proc(using state : ^GameState){
	camera.offset = state.window_size/2.0
	camera.target = player.pos
}

load_texture :: proc(filename: cstring, scale : f32, flip : bool) -> rl.Texture2D{
	img := rl.LoadImage(filename)
	//img =  rl.ImageFromImage(img, {0, 0, f32(img.width), f32(img.height) })
	rl.ImageResize(&img, i32(f32(img.width)*scale), i32(f32(img.height)*scale))


	if flip{
		rl.ImageFlipHorizontal(&img)
	}
	tex := rl.LoadTextureFromImage(img)

	rl.UnloadImage(img)
	return tex
}

update_angel :: proc(using state : ^GameState){

}

create_env_item :: proc(rect: rl.Rectangle, is_finish : bool = false)->EnvItem{
	env : EnvItem
	env.pos  = {rect.x + rect.width/2, rect.y+ rect.height/2}
	env.rect = rect
	env.color = rl.GRAY
	env.collides = true
	env.is_gravity = true
	env.scale = {rect.width, rect.height}
	env.is_finish = is_finish

	if is_finish{
		env.color = rl.RED
	}
	return env
}

main :: proc (){

	using state
	window_size.x = 850
	window_size.y = 850

	rl.InitWindow(i32(window_size.x), i32(window_size.y), "Hello world")
	rl.SetTargetFPS(60)

	player.pos = {20, -20}
	player.speed = 0
	player.canJump = false
	player.scale = 10

	//append(&envs, EnvItem{{0,   0,   1000, 400}, false, rl.LIGHTGRAY})
	append(&envs, create_env_item({-window_size.x/2.0,   0,   300, 100}))
	append(&envs, create_env_item({-window_size.x/2.0,   window_size.y/2-50,   850, 50}))
	append(&envs, create_env_item({-window_size.x/2.0,   -window_size.y/2,   850, 50}))

	append(&envs, create_env_item({-window_size.x/2.0,   -window_size.y/2,   50, 850}))
	append(&envs, create_env_item({window_size.x/2.0-50,   -window_size.y/2,   50, 850}))
	/*
	append(&envs, create_env_item({-window_size.x/2.0+300,   window_size.y/2-100,   100, 100}))
	append(&envs, create_env_item({-window_size.x/2.0+450,   window_size.y/2-100,   100, 100}))
	append(&envs, create_env_item({-window_size.x/2.0+600,   window_size.y/2-100,   100, 100}))
	append(&envs, create_env_item({-window_size.x/2.0+750,   window_size.y/2-100,   100, 100}))
	append(&envs, create_env_item({-window_size.x/2.0+900,   window_size.y/2-100,   100, 100}))
	*/
	append(&envs, create_env_item({0,   0,   100, 100}))
	append(&envs, create_env_item({300,   300,   100, 100}, true))
	append(&envs, create_env_item({200,   0,   100, 100}))
	/*
	append(&envs, EnvItem{{300, 200, 400,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{250, 300, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{650, 300, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{1150, 800, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{1450, 800, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{1650, 800, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{1850, 800, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{2150, 800, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{3150, 800, 100,  10},  true, rl.GRAY})
	append(&envs, EnvItem{{5150, 800, 100,  10},  true, rl.GRAY})
	*/
	//append(&envs, EnvItem{{1150, 300, 100,  10},  true, rl.GRAY})


	//camera.target   = player.pos
	camera.offset   = window_size/2.0
	player.is_falling = true
	camera.rotation = 0
	camera.zoom     = 1.0



	//font := rl.LoadFont("c:/Windows/Fonts/Consola.ttf")

	//Read textures


	append(&angel.texs, load_texture("angel/1.png", 0.5, false)) 
	append(&angel.texs, load_texture("angel/2.png", 0.5, false)) 
	append(&angel.texs, load_texture("angel/3.png", 0.5, false)) 
	append(&angel.texs, load_texture("angel/4.png", 0.5, false)) 

	append(&player_walk[.RIGHT].texs, load_texture("right_walk/1.png", 0.1, false)) 
	append(&player_walk[.RIGHT].texs, load_texture("right_walk/2.png", 0.1, false))
	append(&player_walk[.RIGHT].texs, load_texture("right_walk/3.png", 0.1, false))
	append(&player_walk[.RIGHT].texs, load_texture("right_walk/4.png", 0.1, false))

	append(&player_walk[.LEFT].texs, load_texture("right_walk/1.png", 0.1, true)) 
	append(&player_walk[.LEFT].texs, load_texture("right_walk/2.png", 0.1, true))
	append(&player_walk[.LEFT].texs, load_texture("right_walk/3.png", 0.1, true))
	append(&player_walk[.LEFT].texs, load_texture("right_walk/4.png", 0.1, true))

	append(&player_idle.texs, load_texture("idle/1.png", 0.1, false)) 
	append(&player_idle.texs, load_texture("idle/2.png", 0.1, false)) 


	delta_time : f32
	player_prev_pos : rl.Vector2

	for !rl.WindowShouldClose(){
		delta_time = rl.GetFrameTime()

		//update_player(&state, delta_time)
		camera.zoom += rl.GetMouseWheelMove() * 0.05

		//rl.UpdateCameraPro(&camera, {0,0,0}, {0,0, 90}, 1 )


        if (camera.zoom > 3.0) do camera.zoom = 3.0;
        else if (camera.zoom < 0.25) do camera.zoom = 0.25;

        if rl.IsKeyPressed(.R){
        	//camera.zoom = 1.0
        	//player.pos = {400, 280}
        	//camera.rotation += 90

        	/*
        	mat := linalg.matrix2_rotate_f32(1.5708)

        	//mat := rl.MatrixRotate({0, 0, 0}, 1.5708)

        	for &item in &envs{
        		pos := rl.Vector2{item.rect.x + item.rect.width/2, item.rect.y+ item.rect.height/2}

        		new_pos := mat * pos 
        		item.rect.x = new_pos.x - item.rect.width/2
        		item.rect.y = new_pos.y - item.rect.width/2
        	}

        	player.pos *= mat
        	*/
        	player.orient = .Right

        }

        //update_camera_center(&state)


		rl.BeginDrawing()
			rl.ClearBackground(rl.LIGHTGRAY)

			rl.BeginMode2D(camera)

			//update player
			{
				delta := delta_time * PLAYER_HOR_SPD
				player_ddp : vec2
				v := &player

				if(!v.is_falling){

						/*
						if(is_down(.MOVE_DOWN)){
							player_ddp.y -= 0.1
						}
						if(is_down(.MOVE_UP)){
							player_ddp.y += 0.1
						}
						*/

						if(rl.IsKeyPressed(.SPACE)){
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
							//player_ddp.y -= 0.1
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


			for &item in &envs do rl.DrawRectangleRec(item.rect, item.color)


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
				//rl.DrawTexture(anim.texs[anim.index], i32(player.pos.x-20), i32(player.pos.y) - anim.texs[0].height, rl.WHITE)
				rl.DrawTextureEx(anim.texs[anim.index], player.pos + offset,   rotation, 1, rl.WHITE)
			}

			//rl.DrawRectangleRec(player_rect, rl.RED)

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
			rl.GuiStatusBar({2,2,100,30}, fmt.ctprintf("%f",player.pos))
			rl.GuiStatusBar({2,31,100,30}, fmt.ctprintf("%f",camera.offset))


		rl.EndDrawing()
		player_prev_pos = player.pos
	}
}



























