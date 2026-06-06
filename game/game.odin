package game

import "core:fmt"

import rl "vendor:raylib"
import la "core:math/linalg"

SmoothCam :: struct {
    cam : rl.Camera2D,
    smoothed_cam_pos: [2]f32,
    smooth_cam_speed : f32,
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

    // player body
    hitbox : rl.Rectangle,
    old_pos : [2]f32
}

Game :: struct {
    player: Player,
    level_map: Map,
}

Tiles :: enum { GROUND, SPIKE, SOLID, BACKGROUND }

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
    tile_pos: rl.Vector2,
    texture: rl.Texture2D,
    source: rl.Rectangle,
    dest: rl.Rectangle,
}

Enemy :: struct {
    enemy: rl.Rectangle,
}

collider_for_x :: proc(player: ^Player, hard_rects: ^[]rl.Rectangle) {
    for i in 0..<len(hard_rects) {
        if rl.CheckCollisionRecs(player.hitbox, hard_rects^[i]) {
            player.player_pos.x = player.old_pos.x
            player.hitbox.x = player.old_pos.x + 24
            // fmt.println("\n\n                Collided\n\n")
        } else {
            // fmt.println("\n")
        }
    }
}

collider_for_y :: proc(player: ^Player, hard_rects: ^[]rl.Rectangle) {
    for i in 0..<len(hard_rects) {
        if rl.CheckCollisionRecs(player.hitbox, hard_rects^[i]) {
            player.player_pos.y = player.old_pos.y
            player.hitbox.y = player.old_pos.y + 15
            // fmt.println("\n\n                Collided\n\n")
        } else {
            // fmt.println("\n")
        }
    }
}

run :: proc(player: ^Player, tiles: ^Tile, hard_rects: ^[]rl.Rectangle, camera: ^SmoothCam) {
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
        collider_for_x(player, hard_rects)

        player.player_pos.y += norm_dir.y * player.speed * dt
        player.hitbox.y = player.player_pos.y + 15
        collider_for_y(player, hard_rects)

        c: f32 = camera.smooth_cam_speed * dt
        target_pos : [2]f32 = player.player_pos
        target_pos += {40, 50}
        camera.cam.target += (target_pos - camera.cam.target) * c

        player.dest.x = player.player_pos.x
        player.dest.y = player.player_pos.y

        rl.BeginDrawing()
        rl.ClearBackground({160, 200, 255, 255})
        rl.BeginMode2D(camera.cam)
        // rl.Camera
        // rl.CameraMoveToTarget(camera^, dt)
        // rl.DrawRectangleRec(player, player_pos, rl.GRAY)
        // rl.DrawTextureEx(player.texture, player.player_pos, 0, 3, rl.WHITE)
        // rl.DrawTexturePro(tiles.texture, tiles.source, tiles.dest, {-1280/2, -720/2}, 0, rl.WHITE)
        // rl.DrawTextureEx(tiles.texture, tiles.tile_pos, 0, 5, rl.WHITE)
        rl.DrawTexturePro(player.texture, player.source, player.dest, {0, 0}, 0, rl.WHITE)
        // rl.DrawRectangleRec(hard_rects^[0], rl.WHITE)
        // rl.DrawRectangleRec(hard_rects^[1], rl.BLUE)
        // rl.DrawRectangleRec(hard_rects^[2], rl.GRAY)
        // rl.GetCollisionRec(player.source, hard_rect^) // this will get used for storing the result of collision
        // rl.DrawRectangleLinesEx(player.hitbox, 4, rl.RED)

        rl.EndMode2D()
        rl.EndDrawing()
    }
}

main::proc() {
    screenWidth: i32 = 1920
    screenHeight: i32 = 1080

    rl.InitWindow(screenWidth, screenHeight, "My Odin + Raylib game")
    defer rl.CloseWindow()

    collision_rectangle : rl.Rectangle = {
        x = 600,
        y = 250,
        width = 100,
        height = 100,
    }

    collision_rectangle1 : rl.Rectangle = {
        x = 650,
        y = 280,
        width = 100,
        height = 100,
    }

    collision_rectangle2 : rl.Rectangle = {
        x = 300,
        y = 200,
        width = 300,
        height = 50,
    }

    arr_of_rects: []rl.Rectangle = {
        collision_rectangle,
        // collision_rectangle1,
        // collision_rectangle2,
    }

    player : Player = {
        player_health_points = 5,
        speed = 300,
        texture = rl.LoadTexture("../assets/player/sqPlayer2.png"),
        player_is_hit = false,

        num_frame = 4,
        cur_frame = 0,
        // source refers to -> from where to start drawing
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

    tiles : Tile = {
        texture = rl.LoadTexture("../assets/tiles/ground.png"),

        source = {
            x = 0,
            y = 0,
            width = 16,
            height = 16,
        },

        dest = {
            x = 0,
            y = 0,
            width = 16 * 5,
            height = 16 * 5,
        },
    }

    tiles.tile_pos.x = 600
    tiles.tile_pos.y = 300

    camera : SmoothCam = {
        smooth_cam_speed = 6.0,
        smoothed_cam_pos = {0, 0},
    }
    camera.cam = {
        offset = { cast(f32)(screenWidth / 2.0), cast(f32)(screenHeight / 2.0) },
        // target = player.player_pos,
        rotation = 0.0,
        zoom = 1.3,
    }

    run(&player, &tiles, &arr_of_rects, &camera)
}

