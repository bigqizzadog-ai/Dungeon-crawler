extends Node2D

const GRID := 10
const TILE := 48
const START := Vector2(32, 120)
const CLASSES := [
    {"name": "Fighter", "hp": 14, "attack": 4},
    {"name": "Archer", "hp": 10, "attack": 3},
    {"name": "Mage", "hp": 8, "attack": 5}
]
var chosen := 0
var player := Vector2i(1, 1)
var enemy := Vector2i(7, 7)
var health := 14
var enemy_health := 10
var status := ""
var info: Label

func _ready() -> void:
    info = Label.new()
    info.position = Vector2(32, 16)
    info.add_theme_font_size_override("font_size", 17)
    add_child(info)
    reset(0)

func reset(character: int) -> void:
    chosen = character
    player = Vector2i(1, 1)
    enemy = Vector2i(7, 7)
    health = CLASSES[chosen]["hp"]
    enemy_health = 10
    status = "Find the red enemy. Move adjacent and press Space."
    refresh()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1: reset(0)
        KEY_2: reset(1)
        KEY_3: reset(2)
        KEY_R: reset(chosen)
        KEY_W, KEY_UP: move(Vector2i(0, -1))
        KEY_A, KEY_LEFT: move(Vector2i(-1, 0))
        KEY_S, KEY_DOWN: move(Vector2i(0, 1))
        KEY_D, KEY_RIGHT: move(Vector2i(1, 0))
        KEY_SPACE: attack()

func move(direction: Vector2i) -> void:
    if health <= 0 or enemy_health <= 0:
        return
    var next := player + direction
    if next.x <= 0 or next.x >= GRID - 1 or next.y <= 0 or next.y >= GRID - 1:
        status = "A wall blocks your path."
    elif next == enemy:
        status = "Enemy ahead: press Space to attack."
    else:
        player = next
        status = "Exploring..."
    refresh()

func attack() -> void:
    if health <= 0 or enemy_health <= 0:
        return
    var distance: int = abs(player.x - enemy.x) + abs(player.y - enemy.y)
    if distance != 1:
        status = "Move beside the enemy to attack."
    else:
        enemy_health -= CLASSES[chosen]["attack"]
        if enemy_health <= 0:
            status = "Victory! Press R to play again."
        else:
            health -= 2
            status = "Enemy hits back for 2 HP." if health > 0 else "Defeated. Press R."
    refresh()

func refresh() -> void:
    info.text = "%s | HP: %d | Enemy HP: %d\n%s\n1 Fighter  2 Archer  3 Mage | WASD/arrows | Space attack | R reset" % [
        CLASSES[chosen]["name"], health, max(enemy_health, 0), status
    ]
    queue_redraw()

func _draw() -> void:
    for y in range(GRID):
        for x in range(GRID):
            var corner := START + Vector2(x * TILE, y * TILE)
            var boundary := x == 0 or y == 0 or x == GRID - 1 or y == GRID - 1
            var color := Color(0.18, 0.20, 0.24) if boundary else Color(0.37, 0.39, 0.44)
            draw_rect(Rect2(corner, Vector2(TILE - 2, TILE - 2)), color)
    if enemy_health > 0:
        draw_circle(START + Vector2(enemy * TILE) + Vector2(TILE / 2, TILE / 2), 15, Color(0.95, 0.3, 0.27))
    if health > 0:
        draw_circle(START + Vector2(player * TILE) + Vector2(TILE / 2, TILE / 2), 15, Color(0.29, 0.87, 0.51))
