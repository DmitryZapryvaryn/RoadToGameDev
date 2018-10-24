require 'src/Dependencies'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('Breakdown')

    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 24),
    }
    love.graphics.setFont(gFonts['small'])

    gTextures = {
        ['background'] = love.graphics.newImage('graphics/background.png'),
        ['main'] = love.graphics.newImage('graphics/breakout.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png'),
    }

    gFrames = {
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
        ['balls'] = GenerateQuadsBalls(gTextures['main']),
        ['bricks'] = GenerateQuadsBricks(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
	{
		fullscreen = false,
		resizable = true,
		vsync = true
    })

    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

        ['music'] = love.audio.newSource('sounds/music.wav', 'static'),
    }

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['serve'] = function() return ServeState() end,
        ['play'] = function() return PlayState() end,
    }
    gStateMachine:change('start')
    
    -- table for storing keys which were pressed
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.draw()
    push:start()

    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'],
        -- draw at coordinates 0, 0
        0, 0,
        -- no rotation
        0,
        -- scale factors
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    gStateMachine:render()

    displayFPS()

    push:finish()
end

function displayFPS()
	love.graphics.setFont(gFonts['small'])
	love.graphics.setColor(0 , 1, 0, 1)
	love.graphics.print('FPS:' .. tostring(love.timer.getFPS()), 5, 5)
end

function renderHearts(health)
    local xHearts = VIRTUAL_WIDTH - (MAX_HEALTH * 10) - 10
    local yHearts = 5

    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], xHearts, yHearts)
        xHearts = xHearts + 11
    end

    for i = 1, MAX_HEALTH - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], xHearts, yHearts)
        xHearts = xHearts + 11
    end
end

--[[
    Simply renders the player's score at the top right, with left-side padding
    for the score number.
]]
function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH / 2 , 5)
    love.graphics.printf(tostring(score),  VIRTUAL_WIDTH / 2 + 5, 5, 40, 'right')
end