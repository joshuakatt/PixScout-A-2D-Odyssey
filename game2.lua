local anim8 = require 'libraries/anim8'
local sti = require 'libraries/sti'
local camera = require 'libraries/camera'

local game2 = {}
game2.scale_factor = 2

function math.clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- ensure lower <= upper
    return math.max(lower, math.min(upper, val))
end

function game2.load()
    game2.cam = camera()
    love.graphics.setDefaultFilter("nearest", "nearest")

    game2.gameMap = sti('maps/large_map_1.lua')

    game2.player = {}
    game2.player.x = 400
    game2.player.y = 200
    game2.player.speed = 2
    game2.player.sprite_sheet = love.graphics.newImage('images/sprite_1.png')
    game2.player.grid = anim8.newGrid(12, 18, game2.player.sprite_sheet:getWidth(), game2.player.sprite_sheet:getHeight())
    game2.player.animations = {}
    game2.player.animations.down = anim8.newAnimation(game2.player.grid('1-4', 1), 0.2)
    game2.player.animations.left = anim8.newAnimation(game2.player.grid('1-4', 2), 0.2)
    game2.player.animations.right = anim8.newAnimation(game2.player.grid('1-4', 3), 0.2)
    game2.player.animations.up = anim8.newAnimation(game2.player.grid('1-4', 4), 0.2)
    game2.player.anim = game2.player.animations.left

    game2.cam:lookAt(game2.player.x, game2.player.y)  -- moved here after player definition

    game2.isInGame = false
    game2.playerName = ""

    game2.menuBgAnim = 0 -- For simple background animation

    game2.titleFont = love.graphics.newFont(40)
end

function game2.textinput(t)
    if not game2.isInGame then
        game2.playerName = game2.playerName .. t
    end
end

function game2.update(dt)
    if love.keyboard.isDown('return') and not game2.isInGame then
        game2.isInGame = true
    end

    if game2.isInGame then
        local isMoving = false

        game2.player.anim:update(dt)
        game2.cam:lookAt(game2.player.x * game2.scale_factor, game2.player.y * game2.scale_factor)

        if love.keyboard.isDown("right") then
            game2.player.x = game2.player.x + game2.player.speed
            game2.player.anim = game2.player.animations.right
            isMoving = true
        end
        if love.keyboard.isDown("left") then
            game2.player.x = game2.player.x - game2.player.speed
            game2.player.anim = game2.player.animations.left
            isMoving = true
        end
        if love.keyboard.isDown("down") then
            game2.player.y = game2.player.y + game2.player.speed
            game2.player.anim = game2.player.animations.down
            isMoving = true
        end
        if love.keyboard.isDown("up") then
            game2.player.y = game2.player.y - game2.player.speed
            game2.player.anim = game2.player.animations.up
            isMoving = true
        end
        if not isMoving then
            game2.player.anim:gotoFrame(2)
        end

        game2.player.anim:update(dt)
        game2.cam:lookAt(game2.player.x * game2.scale_factor, game2.player.y * game2.scale_factor)
        local w = love.graphics.getWidth() / game2.scale_factor
        local h = love.graphics.getHeight() / game2.scale_factor
        local mapW = game2.gameMap.width * game2.gameMap.tilewidth
        local mapH = game2.gameMap.height * game2.gameMap.tileheight

        game2.cam.x, game2.cam.y = math.clamp(game2.player.x, w / 2, mapW - w / 2), math.clamp(game2.player.y, h / 2, mapH - h / 2)
    else
        game2.menuBgAnim = (game2.menuBgAnim + dt) % (2 * math.pi) -- simple sine wave animation
    end
end

function game2.drawWave(offsetY, color, amplitude)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    love.graphics.setColor(color)
    for x = 0, w, 5 do
        local y = offsetY + amplitude * math.sin((x + game2.menuBgAnim * 100) / 100)
        love.graphics.circle('fill', x, y, 3) -- draw a small circle at (x, y)
    end    
end

function game2.draw()
    if game2.isInGame then
        game2.cam:lookAt(game2.player.x * game2.scale_factor, game2.player.y * game2.scale_factor)
        game2.cam:attach()
        love.graphics.scale(game2.scale_factor, game2.scale_factor)
        game2.gameMap:drawLayer(game2.gameMap.layers["Tile Layer 1"])
        game2.gameMap:drawLayer(game2.gameMap.layers["upper_1"])
        game2.player.anim:draw(game2.player.sprite_sheet, game2.player.x, game2.player.y, nil, 1, 1, 6, 9)
        game2.cam:detach()    
    else
        love.graphics.setBackgroundColor(0.2, 0.2, 0.2) -- dark gray background
        local h = love.graphics.getHeight()

        game2.drawWave(h / 2 - 50, {0.5, 0.3, 0.3}, 50) -- offset of -50, reddish color
        game2.drawWave(h / 2, {0.5, 0.5, 0.5}, 50) -- no offset, gray color
        game2.drawWave(h / 2 + 50, {0.3, 0.3, 0.5}, 50) -- offset of 50, bluish color

        love.graphics.setColor(1, 1, 1) -- white text

        -- Draw game title
        love.graphics.setFont(game2.titleFont)
        love.graphics.printf("PixScout A 2D Odyssey", 0, h / 2 - 100, love.graphics.getWidth(), "center")

        -- Draw the input prompt and entered name
        love.graphics.setFont(love.graphics.newFont(14)) -- Reset to smaller font for other text
        love.graphics.printf("Enter your name and press Return to start the game:", 0, h / 2 - 20, love.graphics.getWidth(), "center")
        love.graphics.printf(game2.playerName, 0, h / 2, love.graphics.getWidth(), "center")
    end
end

return game2
