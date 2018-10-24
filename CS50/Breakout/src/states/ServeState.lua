ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score

    self.ball = Ball(math.random(7))
end

function ServeState:update(dt)
    self.paddle:update(dt)

    self.ball.x = self.paddle.x + (self.paddle.width / 2) - (self.ball.width / 2)
    self.ball.y = self.paddle.y - self.ball.height - 2

    if love.keyboard.wasPressed('space') then
        gStateMachine:change('play', {
            paddle = self.paddle,
            ball = self.ball,
            bricks = self.bricks,
            health = self.health,
            score = self.score
        })
    end 

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHearts(self.health)
end