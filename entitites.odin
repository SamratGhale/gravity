package main
import "core:math/linalg"
import "core:fmt"

MoveSpec :: struct{
	speed, drag: f32,
}

test_wall:: proc(wall_x, rel_x, rel_y, p_delta_x,
	p_delta_y: f32, t_min: ^f32, min_y, max_y:f32)->b32 {
	hit :b32= false;
	t_epsilon :f32= 0.001;
	if (p_delta_x != 0.0) {
		t_result :f32= (wall_x - rel_x) / p_delta_x;
		y :f32= rel_y + t_result * p_delta_y;
		if ((t_result >= 0.0) && (t_min^ > t_result)) {
			if ((y >= min_y) && (y <= max_y)) {
				t_min^ = max(0.0, t_result - t_epsilon);
				hit = true;
			}
		}
	}
	return hit;
}


move_player :: proc (
	game_state: ^GameState,
	entity : ^Player,
	old_ddp: vec2,
	dt : f32,
	move_spec: MoveSpec,
	){

	//fmt.println(dt)


	ddp := old_ddp

	ddp *= move_spec.speed
	ddp -= (move_spec.drag * entity.dp)
	delta := (0.5 * ddp * dt * dt + entity.dp * dt)

	entity.dp   = ddp * dt + entity.dp

	level := state.levels[state.curr_level]

	for j in 0..<4{
		t_min :f32= 1.0
		wall_normal :vec2 = {}
		hit_entity_index :int= -1;
		desired_pos := entity.pos + delta

		offset      : vec2 = {8, 5}
		test_offset : vec2 = {2, 3}

		for &v, i in &level.envs{
			if(v.collides){
				scale_sum  := v.scale + entity.scale
				min_corner := -0.5 * scale_sum
				max_corner := +0.5 * scale_sum

				rel := entity.pos - v.pos

				if (test_wall(min_corner.x, rel.x, rel.y, delta.x, delta.y, &t_min,
					min_corner.y, max_corner.y)) {
					wall_normal = {-1, 0};
					hit_entity_index = i;
					fmt.println("first")
				}
				if (test_wall(max_corner.x, rel.x, rel.y, delta.x, delta.y, &t_min,
					min_corner.y, max_corner.y)) {
					wall_normal = {1, 0};
					hit_entity_index = i;
					fmt.println("second")
				}
				if (test_wall(max_corner.y, rel.y, rel.x, delta.y, delta.x, &t_min,
					min_corner.x, max_corner.x)) {
					wall_normal = {0, 1};
					hit_entity_index = i;
					fmt.println("third")
				}

				if (test_wall(min_corner.y, rel.y, rel.x, delta.y, delta.x, &t_min, min_corner.x, max_corner.x)) {
					wall_normal      = {0, -1};
					hit_entity_index = i;
					fmt.println("fourth")
				}

				if(v.is_gravity){
					if (test_wall(min_corner.y+test_offset.y, rel.y, rel.x, delta.y, delta.x, &t_min, min_corner.x, max_corner.x+test_offset.x)) {
						if(entity.orient != .Top){
							fmt.println("Flip to boottom")
							entity.orient = .Top
							entity.dp.x = entity.dp.y
							entity.dp.y = 0
							entity.pos += {-offset.x, -offset.y}
						}
					}
					if (test_wall(min_corner.y + test_offset.y, rel.y, rel.x, delta.y, delta.x, &t_min, min_corner.x-test_offset.x, max_corner.x)) {
						if(entity.orient != .Top){
							fmt.println("Flip to bottom")
							entity.orient = .Top
							entity.dp.x -= entity.dp.y
							entity.dp.y = 0
							entity.pos += {offset.x, -offset.y}
						}
					}


					if (test_wall(max_corner.y - test_offset.y, rel.y, rel.x, delta.y, delta.x, &t_min, min_corner.x, max_corner.x + test_offset.x)) {
						wall_normal = {0, 1};
								//hit_entity_index = i;
								if(entity.orient != .Buttom){
									fmt.println("Flip to top")
									entity.orient = .Buttom
									entity.dp.x = -entity.dp.y
									entity.dp.y = 0
									entity.pos += {-offset.x, offset.y}
								}
							}

							if (test_wall(max_corner.y - test_offset.y, rel.y, rel.x, delta.y, delta.x, &t_min, min_corner.x - test_offset.x, max_corner.x)) {
								wall_normal = {0, 1};
								//hit_entity_index = i;
								if(entity.orient != .Buttom){
									fmt.println("Flip to top")
									entity.orient = .Buttom
									entity.dp.x = entity.dp.y
									entity.dp.y = 0
									entity.pos += {offset.x, offset.y}
								}
							}

							if (test_wall(max_corner.x - test_offset.y, rel.x, rel.y , delta.x , delta.y, &t_min, min_corner.y, max_corner.y + test_offset.x)) {
								//wall_normal = {1, 0};
								//hit_entity_index = i;
								if(entity.orient != .Right){
									fmt.println("Flip to right 1")
									entity.orient = .Right
									entity.dp.y = -entity.dp.x
									entity.dp.x = 0
									entity.pos += {offset.y, -offset.x}
								}
							}

							if (test_wall(max_corner.x - test_offset.y, rel.x, rel.y , delta.x , delta.y, &t_min, min_corner.y- test_offset.x, max_corner.y)) {
								//wall_normal = {1, 0};
								//hit_entity_index = i;
								if(entity.orient != .Right){
									fmt.println("Flip to right 2")
									entity.orient = .Right
									entity.dp.y = entity.dp.x
									entity.dp.x = 0
									entity.pos += {offset.y, offset.x}
								}
							}


							if (test_wall(min_corner.x + test_offset.y, rel.x, rel.y, delta.x, delta.y, &t_min, min_corner.y, max_corner.y+ test_offset.x)) {
								if(entity.orient != .Left){
									fmt.println("Flip to left")
									entity.orient = .Left
									entity.dp.y = entity.dp.x
									entity.dp.x = 0
									entity.pos += {-offset.y, -offset.x}
								}
							}

							if (test_wall(min_corner.x + test_offset.y, rel.x, rel.y, delta.x, delta.y, &t_min, min_corner.y - test_offset.x, max_corner.y)) {

								if(entity.orient != .Left){
									fmt.println("Flip left")
									entity.orient = .Left
									entity.dp.y -= entity.dp.x
									entity.dp.x = 0
									entity.pos += {-offset.y, offset.x}
								}
							}


						}
					}

				}
				entity.pos += t_min * delta
				if(hit_entity_index != -1){
					entity.is_falling = false;
					entity.dp = entity.dp -1 * linalg.inner_product(entity.dp, wall_normal) * wall_normal
					delta = desired_pos - entity.pos
					delta = delta -1 *  linalg.inner_product(delta,wall_normal) * wall_normal

					test_entity := level.envs[hit_entity_index]

					if(test_entity.is_finish){

                        level := &state.levels[state.current_level]

                        if test_entity.scale.x > test_entity.scale.y{
                            //in this case the player should be either buttom or top
                            if entity.orient == .Left || entity.orient == .Right{
                                level.is_finished = true
                                state.mode = .LEVEL_SELECTOR
                                fmt.println("LEVEL COMPLETED !")
                            }
                        }else{
                            if entity.orient == .Top || entity.orient == .Buttom{
                                level.is_finished = true
                                state.mode = .LEVEL_SELECTOR
                                fmt.println("LEVEL COMPLETED !")
                            }
                        }
                            

                        //Go to next level
					}
				}else{
					break;
				}
			}
	//entity.pos += delta
}
