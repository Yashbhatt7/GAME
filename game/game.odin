package game

import "core:fmt"

import rl "vendor:raylib"
import la "core:math/linalg"

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

    // player body
    hitbox : rl.Rectangle,
    old_pos : [2]f32
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

run :: proc(player: ^Player, hard_rect: ^rl.Rectangle) {
    for !rl.WindowShouldClose() {
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

        fmt.println(dir.x, dir.y)
        dt : f32 = rl.GetFrameTime()

        player.old_pos = player.player_pos
        norm_dir := la.normalize0(dir)

        player.player_pos.x += norm_dir.x * player.speed * dt;
        player.hitbox.x = player.player_pos.x + 24
        if rl.CheckCollisionRecs(player.hitbox, hard_rect^) {
            player.player_pos.x = player.old_pos.x
            player.hitbox.x = player.old_pos.x + 24

            fmt.println("\n\n                Collided\n\n")
        } else {
            fmt.println("\n")
        }

        player.player_pos.y += norm_dir.y * player.speed * dt
        player.hitbox.y = player.player_pos.y + 15
        if rl.CheckCollisionRecs(player.hitbox, hard_rect^) {
            player.player_pos.y = player.old_pos.y
            player.hitbox.y = player.old_pos.y + 15
        }

        player.dest.x = player.player_pos.x
        player.dest.y = player.player_pos.y

        rl.BeginDrawing()
        rl.ClearBackground({160, 200, 255, 255})
        // rl.DrawRectangleRec(player, player_pos, rl.GRAY)
        // rl.DrawTextureEx(player.texture, player.player_pos, 0, 3, rl.WHITE)
        rl.DrawTexturePro(player.texture, player.source, player.dest, {0, 0}, 0, rl.WHITE)
        rl.DrawRectangleRec(hard_rect^, rl.WHITE)
        // rl.GetCollisionRec(player.source, hard_rect^) // this will get used for storing the result of collision
        // rl.DrawRectangleLinesEx(player.hitbox, 4, rl.RED)



        rl.EndDrawing()
    }
}

main::proc() {
    rl.InitWindow(1280, 720, "My Odin + Raylib game")
    defer rl.CloseWindow()

    collision_rectangle : rl.Rectangle = {
        x = 600,
        y = 250,
        width = 100,
        height = 100,
    }

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
        },

        hitbox = {
            width = 32.0 * 3 - 48,
            height = 32.0 * 3 - 15,
        },
    }

    run(&player, &collision_rectangle)
}

