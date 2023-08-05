local anim8 = require 'libraries/anim8'
local sti = require 'libraries/sti'
local camera = require 'libraries/camera'

local game1 = {}

function game1.load()
    game1.cam = camera()
    love.graphics.setDefaultFilter("nearest", "nearest")

    game1.gameMap = sti('maps/test_map_1.lua')

    game1.player = {}
    game1.player.x = 400
    game1.player.y = 200
    game1.player.speed = 5
    game1.player.sprite_sheet = love.graphics.newImage('images/sprite_1.png')
    game1.player.grid = anim8.newGrid(12, 18, game1.player.sprite_sheet:getWidth(), game1.player.sprite_sheet:getHeight())
    game1.player.animations = {}
    game1.player.animations.down = anim8.newAnimation(game1.player.grid('1-4', 1), 0.2)
    game1.player.animations.left = anim8.newAnimation(game1.player.grid('1-4', 2), 0.2)
    game1.player.animations.right = anim8.newAnimation(game1.player.grid('1-4', 3), 0.2)
    game1.player.animations.up = anim8.newAnimation(game1.player.grid('1-4', 4), 0.2)
    game1.player.anim = game1.player.animations.left

    game1.isInGame = false
    game1.playerName = ""

    game1.menuBgAnim = 0 -- For simple background animation

    game1.titleFont = love.graphics.newFont(40)
end

function game1.textinput(t)
    if not game1.isInGame then
        game1.playerName = game1.playerName .. t
    end
end

function game1.update(dt)
    if love.keyboard.isDown('return') and not game1.isInGame then
        game1.isInGame = true
    end

    if game1.isInGame then
        local isMoving = false

        if love.keyboard.isDown("right") then
            game1.player.x = game1.player.x + game1.player.speed
            game1.player.anim = game1.player.animations.right
            isMoving = true
        end
        if love.keyboard.isDown("left") then
            game1.player.x = game1.player.x - game1.player.speed
            game1.player.anim = game1.player.animations.left
            isMoving = true
        end
        if love.keyboard.isDown("down") then
            game1.player.y = game1.player.y + game1.player.speed
            game1.player.anim = game1.player.animations.down
            isMoving = true
        end
        if love.keyboard.isDown("up") then
            game1.player.y = game1.player.y - game1.player.speed
            game1.player.anim = game1.player.animations.up
            isMoving = true
        end
        if not isMoving then
            game1.player.anim:gotoFrame(2)
        end

        game1.player.anim:update(dt)
        game1.cam:lookAt(game1.player.x, game1.player.y)

        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        local mapW = game1.gameMap.width * game1.gameMap.tilewidth
        local mapH = game1.gameMap.height * game1.gameMap.tileheight

        if game1.cam.x < w / 2 then
            game1.cam.x = w / 2
        end
        if game1.cam.x > (mapW - w / 2) then
            game1.cam.x = (mapW - w / 2)
        end
        if game1.cam.y > (mapH - h / 2) then
            game1.cam.y = (mapH - h / 2)
        end
        if game1.cam.y < h / 2 then
            game1.cam.y = h / 2
        end
    else
        game1.menuBgAnim = (game1.menuBgAnim + dt) % (2 * math.pi) -- simple sine wave animation
    end
end

function game1.drawWave(offsetY, color, amplitude)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    love.graphics.setColor(color)
    for x = 0, w, 5 do
        local y = offsetY + amplitude * math.sin((x + game1.menuBgAnim * 100) / 100)
        love.graphics.circle('fill', x, y, 3) -- draw a small circle at (x, y)
    end
end

function game1.draw()
    if game1.isInGame then
        game1.cam:attach()
        game1.gameMap:drawLayer(game1.gameMap.layers["Tile Layer 1"])
        game1.gameMap:drawLayer(game1.gameMap.layers["Trees"])
        game1.player.anim:draw(game1.player.sprite_sheet, game1.player.x, game1.player.y, nil, 6, nil, 6, 9)
        game1.cam:detach()   
    else
        love.graphics.setBackgroundColor(0.2, 0.2, 0.2) -- dark gray background
        local h = love.graphics.getHeight()

        game1.drawWave(h / 2 - 50, {0.5, 0.3, 0.3}, 50) -- offset of -50, reddish color
        game1.drawWave(h / 2, {0.5, 0.5, 0.5}, 50) -- no offset, gray color
        game1.drawWave(h / 2 + 50, {0.3, 0.3, 0.5}, 50) -- offset of 50, bluish color

        love.graphics.setColor(1, 1, 1) -- white text

        -- Draw game title
        love.graphics.setFont(game1.titleFont)
        love.graphics.printf("PixScout A 2D Odyssey", 0, h / 2 - 100, love.graphics.getWidth(), "center")

        -- Draw the input prompt and entered name
        love.graphics.setFont(love.graphics.newFont(14)) -- Reset to smaller font for other text
        love.graphics.printf("Enter your name and press Return to start the game:", 0, h / 2 - 20, love.graphics.getWidth(), "center")
        love.graphics.printf(game1.playerName, 0, h / 2, love.graphics.getWidth(), "center")
    end
end

return game1
