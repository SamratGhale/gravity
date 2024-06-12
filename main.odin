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

GameMode :: enum {
	MENU,
	LEVEL_SELECTOR,
	PLAY,
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

	current_level: u32,

}

Anim :: struct {
	texs   : [dynamic]rl.Texture,
	index  : u32,
	stride : u32,
}

EnvItem :: struct{
	using base : EntityBase,
	rect       : rl.Rectangle,
	color      : rl.Color,
	is_finish  : bool, //this means that if the player touches this then the level is over
}



GameState :: struct{
	player      : Player,
	//envs        : [dynamic]EnvItem,
	window_size : rl.Vector2,
	camera      : rl.Camera2D,
	angel       : Anim,

	player_walk : [FaceDirection]Anim,
	player_idle : Anim,

	player_prev_pos : rl.Vector2,
	levels : [dynamic]Level,
	
	mode : GameMode,
	curr_level: u32,
	menu : Menu,
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

	level := state.levels[state.curr_level]
	for &item in &level.envs{
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

	init_levels()

	rl.SetExitKey(.LEFT_ALT | .F4)



	for !rl.WindowShouldClose(){

		switch state.mode{
			case .MENU:{
				render_menu()
			}
			case .LEVEL_SELECTOR:{
				render_menu()
			}
			case .PLAY:{
				render_game()
			}
		}

	}
}



























