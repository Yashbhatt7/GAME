package game

import "core:fmt"

import rl "vendor:raylib"
import la "core:math/linalg"

Vector2 :: struct {
    x: f32,
    y: f32,
}

Player :: struct {
    player_health_points: int,
    speed : f32,
    player_pos : [2]f32,
    texture: rl.Texture2D,
    player_is_hit: bool,

    // sprite sheet info
    num_frame: f32,
    cur_frame: f32,
    // anim_timer: f32,
    // anim_speed: f32,

    source: rl.Rectangle,
    dest: rl.Rectangle,

    direction: Direction,

}

Game :: struct {
    player: Player,
    level_map: Map,
}

Tiles :: enum { SPIKE, SOLID, BACKGROUND }

// player direction
Direction :: enum {
    DOWN = 0,
    UP = 1,
    RIGHT = 2,
    LEFT = 3,
}

Tile :: struct {
    id: int,
    solid: bool,
    texture: rl.Texture2D,

}

run :: proc(player: ^Player) {
    for !rl.WindowShouldClose() {
        dt : f32 = rl.GetFrameTime()

        dir : [2]f32

        if rl.IsKeyDown(.S) {
            dir.y += 1;
            player.source.x = 0;
        }
        if rl.IsKeyDown(.W) {
            dir.y -= 1;
            player.source.x = 32 * 1;
        }
        if rl.IsKeyDown(.D) {
            dir.x += 1;
            player.source.x = 32 * 2;
        }
        if rl.IsKeyDown(.A) {
            dir.x -= 1;
            player.source.x = 32 * 3;
        }

        player.player_pos += la.normalize0(dir) * player.speed * dt;
        player.dest.x = player.player_pos.x
        player.dest.y = player.player_pos.y

        rl.BeginDrawing()
        rl.ClearBackground({160, 200, 255, 255})
        // rl.DrawRectangleRec(player, player_pos, rl.GRAY)
        // rl.DrawTextureEx(player.texture, player.player_pos, 0, 3, rl.WHITE)
        rl.DrawTexturePro(player.texture, player.source, player.dest, {0, 0}, 0, rl.WHITE)

        rl.EndDrawing()
    }
}

main::proc() {
    rl.InitWindow(1280, 720, "My Odin + Raylib game")
    defer rl.CloseWindow()

    player : Player = {
        player_health_points = 5,
        speed = 300,
        texture = rl.LoadTexture("../assets/player/sqPlayer2.png"),
        player_is_hit = false,

        num_frame = 4,
        cur_frame = 0,
        source = {
            x = 0.0,
            y = 0.0,
            width = 32.0,
            height = 32.0,
        },

        dest = {
            x = 30.0,
            y = 30.0,
            width = 32.0 * 3,
            height = 32.0 * 3,
        }
    };

    run(&player)
}

