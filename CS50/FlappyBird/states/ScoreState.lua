ScoreState = Class{__includes = BaseState}

local BRONZE_LIMIT = 2
local SILVER_LIMIT = 4
local GOLD_LIMIT = 6

function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
end

function ScoreState:render()

    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 124, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)

    if self.score < BRONZE_LIMIT then
        medal = love.graphics.newImage('resources/images/bronze_medal.png')
        love.graphics.draw(medal, VIRTUAL_WIDTH / 2 - medal:getWidth() / 2, 30)
        love.graphics.printf('Not bad... for newbie!', 0, 160, VIRTUAL_WIDTH, 'center')
    elseif self.score < SILVER_LIMIT then
        medal = love.graphics.newImage('resources/images/silver_medal.png')
        love.graphics.draw(medal, VIRTUAL_WIDTH / 2 - medal:getWidth() / 2, 30)
        love.graphics.printf('Not bad!', 0, 160, VIRTUAL_WIDTH, 'center')
    else
        medal = love.graphics.newImage('resources/images/gold_medal.png')
        love.graphics.draw(medal, VIRTUAL_WIDTH / 2 - medal:getWidth() / 2, 30)
        love.graphics.printf('Flappy King!', 0, 160, VIRTUAL_WIDTH, 'center')
    end

    

    --love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 180, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 240, VIRTUAL_WIDTH, 'center')
end