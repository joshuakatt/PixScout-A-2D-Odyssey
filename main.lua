-- main.lua file
local menu = require 'menu'
local game1 = require 'game1'
local game2 = require 'game2'

function love.load()
    menu.load({game1, game2}) -- pass both games to the menu load function
end

function love.update(dt)
    menu.update(dt)
end

function love.draw()
    menu.draw()
end

function love.keypressed(key)
    menu.keypressed(key)
end
