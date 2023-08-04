function love.load()
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    camera = require 'libraries/camera'

    cam = camera()
    love.graphics.setDefaultFilter("nearest", "nearest")

    gameMap = sti('maps/test_map_1.lua')

    player = {}
    player.x = 400
    player.y = 200
    player.speed = 5
    player.sprite_sheet = love.graphics.newImage('images/sprite_1.png')
    player.grid = anim8.newGrid(12, 18, player.sprite_sheet:getWidth(), player.sprite_sheet:getHeight())
    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.anim = player.animations.left

    isInGame = false
    playerName = ""

    menuBgAnim = 0 -- For simple background animation

    titleFont = love.graphics.newFont(40)
end

function love.textinput(t)
    if not isInGame then
        playerName = playerName .. t
    end
end

function love.update(dt)
    if love.keyboard.isDown('return') and not isInGame then
        isInGame = true
    end

    if isInGame then
        local isMoving = false

        if love.keyboard.isDown("right") then
            player.x = player.x + player.speed
            player.anim = player.animations.right
            isMoving = true
        end
        if love.keyboard.isDown("left") then
            player.x = player.x - player.speed
            player.anim = player.animations.left
            isMoving = true
        end
        if love.keyboard.isDown("down") then
            player.y = player.y + player.speed
            player.anim = player.animations.down
            isMoving = true
        end
        if love.keyboard.isDown("up") then
            player.y = player.y - player.speed
            player.anim = player.animations.up
            isMoving = true
        end
        if not isMoving then
            player.anim:gotoFrame(2)
        end

        player.anim:update(dt)
        cam:lookAt(player.x, player.y)

        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        local mapW = gameMap.width * gameMap.tilewidth
        local mapH = gameMap.height * gameMap.tileheight

        if cam.x < w / 2 then
            cam.x = w / 2
        end
        if cam.x > (mapW - w / 2) then
            cam.x = (mapW - w / 2)
        end
        if cam.y > (mapH - h / 2) then
            cam.y = (mapH - h / 2)
        end
        if cam.y < h / 2 then
            cam.y = h / 2
        end
    else
        menuBgAnim = (menuBgAnim + dt) % (2 * math.pi) -- simple sine wave animation
    end
end

function drawWave(offsetY, color, amplitude)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    love.graphics.setColor(color)
    for x = 0, w, 5 do
        local y = offsetY + amplitude * math.sin((x + menuBgAnim * 100) / 100)
        love.graphics.circle('fill', x, y, 3) -- draw a small circle at (x, y)
    end
end

function love.draw()
    if isInGame then
        cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        player.anim:draw(player.sprite_sheet, player.x, player.y, nil, 6, nil, 6, 9)
        cam:detach()   
    else
        love.graphics.setBackgroundColor(0.2, 0.2, 0.2) -- dark gray background
        local h = love.graphics.getHeight()

        drawWave(h / 2 - 50, {0.5, 0.3, 0.3}, 50) -- offset of -50, reddish color
        drawWave(h / 2, {0.5, 0.5, 0.5}, 50) -- no offset, gray color
        drawWave(h / 2 + 50, {0.3, 0.3, 0.5}, 50) -- offset of 50, bluish color

        love.graphics.setColor(1, 1, 1) -- white text

        -- Draw game title
        love.graphics.setFont(titleFont)
        love.graphics.printf("PixScout A 2D Odyssey", 0, h / 2 - 100, love.graphics.getWidth(), "center")

        -- Draw the input prompt and entered name
        love.graphics.setFont(love.graphics.newFont(14)) -- Reset to smaller font for other text
        love.graphics.printf("Enter your name and press Return to start the game:", 0, h / 2 - 20, love.graphics.getWidth(), "center")
        love.graphics.printf(playerName, 0, h / 2, love.graphics.getWidth(), "center")
    end
end
