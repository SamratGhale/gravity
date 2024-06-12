package main
import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

Menu :: struct {
	selected : Options,
}


Options :: enum {
	START_GAME,
	LEVEL_SELECTOR,
	EXIT,
} ;

render_menu :: proc(){

	rl.BeginDrawing()
	rl.DrawRectangle(0, 0, i32(state.window_size.x), i32(state.window_size.y), rl.LIGHTGRAY);
	//rl.DrawText("MENU", 20, 20, 40, rl.DARKBLUE);
	//rl.DrawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, rl.DARKBLUE);

	x, y :i32 =  170, 200

	for option, i in Options{
		str, _ := fmt.enum_value_to_string(option)
		cstr   := strings.unsafe_string_to_cstring(str)
		if state.menu.selected == option{
			rl.DrawRectangle(x, y, i32(len(str) * 25) , 30, rl.PURPLE);
		}
		rl.DrawText(cstr, x, y, 30, rl.BLACK)

		y += 30
	}

	if rl.IsKeyPressed(.DOWN){
		val := int(state.menu.selected) +1
		state.menu.selected = Options(val%len(Options))
	}
	if rl.IsKeyPressed(.UP){
		val := int(state.menu.selected) -1
		if val <0{
			val = len(Options)-1
		}
		state.menu.selected = Options(val)
	}

	if rl.IsKeyPressed(.ENTER){
		switch(state.menu.selected){
			case .START_GAME:{
				state.mode = .PLAY
			}
			case .LEVEL_SELECTOR:{
				state.mode = .LEVEL_SELECTOR
			}
			case .EXIT:{
			}
		}
	}


	rl.EndDrawing()

}


render_level_selector :: proc(){

}