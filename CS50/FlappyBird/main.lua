push = require 'push'
Class = require("class")

require 'Bird'

require 'Pipe'

require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.png')
local backgroundScroll = 0
local BACKGROUND_SCROLL_SPEED = 30
local BACKGROUND_LOOPING_POINT = 413

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0
local GROUND_SCROLL_SPEED = 60

local bird = Bird()
local pipePairs = {}

local spawnTimer = 0
local spawnDelay = 2

-- init our last recorded Y value for a gap placement to base other gaps
local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Flappy Bird')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
	{
		fullscreen = false,
		resizable = true,
		vsync = true
    })
    
    -- table for storing keys which were pressed
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if scrolling then
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
     % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
     % VIRTUAL_WIDTH

    spawnTimer = spawnTimer + dt

    if spawnTimer > spawnDelay then
        local y =  math.max( -PIPE_HEIGHT + 20, 
            math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 80 - PIPE_HEIGHT))
        lastY = y

        table.insert(pipePairs, PipePair(y))
        spawnTimer = 0
        spawnDelay = math.random() + math.random(2, 5)
    end


    bird:update(dt)

    for k, pipePair in pairs(pipePairs) do
        pipePair:update(dt)

        for l, pipe in pairs(pipePair.pipes) do
            if bird:collides(pipe) then
                scrolling = false
            end
        end

        if pipePair.remove then
            table.remove(pipePairs, k)
        end
    end
end

    love.keyboard.keysPressed = {}

end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

	if key == 'escape' then
        love.event.quit()
	end
end

-- override function wasPressed to grant access outside main.lua
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.draw()
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255) -- values [0, 1] - Normalization
    
    love.graphics.draw(background, -backgroundScroll, 0)

    for k, pipePair in pairs(pipePairs) do
        pipePair:render()
    end

    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - ground:getHeight())

    bird:render()
    
    push:finish()
end