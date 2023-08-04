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
    player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation( player.grid('1-4', 4), 0.2)
    player.anim = player.animations.left

end

 function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("right") then
        player.x = player.x+player.speed
        player.anim = player.animations.right
        isMoving = true
    end
    if love.keyboard.isDown("left") then
        player.x = player.x-player.speed
        player.anim = player.animations.left
        isMoving = true
    end
    if love.keyboard.isDown("down") then
        player.y = player.y+player.speed
        player.anim = player.animations.down
        isMoving = true
    end
    if love.keyboard.isDown("up") then
        player.y = player.y-player.speed
        player.anim = player.animations.up
        isMoving = true
    end
    if isMoving == false then
        player.anim:gotoFrame(2)
    end
    player.anim:update(dt)
 
    cam:lookAt(player.x, player.y)
    local w= love.graphics.getWidth()
    local h= love.graphics.getHeight()
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x < w/2 then
        cam.x = w/2
    end
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end
    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2) -- This line was previously cam.x
    end
    if cam.y < h/2 then
        cam.y = h/2
    end


 end

 function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        player.anim:draw(player.sprite_sheet, player.x, player.y, nil, 6, nil, 6, 9)
    cam:detach()   
 end
