-- menu.lua file
local menu = {}

local games
local currentGame = nil
local titleFont
local choiceFont

function menu.load(gameList)
    games = gameList
    titleFont = love.graphics.newFont(32)
    choiceFont = love.graphics.newFont(20)
end

function menu.update(dt)
    if currentGame then
        currentGame.update(dt)
    end
end

function menu.draw()
    if currentGame then
        currentGame.draw()
    else
        local h = love.graphics.getHeight()
        local w = love.graphics.getWidth()
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1) -- White color

        -- Draw title
        love.graphics.setFont(titleFont)
        love.graphics.printf("Choose a game to start", 0, h / 2 - 50, w, "center")

        -- Draw choices
        love.graphics.setFont(choiceFont)
        love.graphics.printf("1. Game 1", 0, h / 2 - 10, w, "center")
        love.graphics.printf("2. Game 2", 0, h / 2 + 10, w, "center")
    end
end

function menu.keypressed(key)
    if currentGame then
        if key == 'escape' then -- Let's say we return to the menu with the Escape key
            currentGame = nil
        else
            if currentGame.keypressed then -- check if the function exists
                currentGame.keypressed(key)
            end
        end
    else
        if key == '1' then
            currentGame = games[1]
            currentGame.load()
        elseif key == '2' then
            currentGame = games[2]
            currentGame.load()
        end
    end
end


return menu
