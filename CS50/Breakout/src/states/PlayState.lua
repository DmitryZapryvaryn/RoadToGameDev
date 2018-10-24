PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle
    self.ball = params.ball
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score

    self.ball.dx = math.random( -100, 100 )
    self.ball.dy = -100

    self.paused = false
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
        self.ball.y = self.paddle.y - self.ball.height
        self.ball.dy = -self.ball.dy

        -- if we hit the paddle on its left side while moving left... and self.paddle.dx < 0
        if self.ball.x + self.ball.width < self.paddle.x + (self.paddle.width / 2)  then
            self.ball.dx = -math.pow((self.paddle.x + (self.paddle.width / 2) - (self.ball.x + (self.ball.width / 2))), 2) * ANGLE_MULTIPLIER
            
        -- else if we hit the paddle on its right side while moving right... and self.paddle.dx > 0
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2)  then
            self.ball.dx = math.pow(math.abs(self.paddle.x + (self.paddle.width / 2) - (self.ball.x + (self.ball.width / 2))), 2) * ANGLE_MULTIPLIER
        end

        gSounds['paddle-hit']:play()
    end

    for k, brick in pairs(self.bricks) do
        if brick.inPlay and self.ball:collides(brick) then
            brick:hit()
            self.score = self.score + 50
            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            
            -- top edge if no X collisions, always check
            elseif self.ball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            end

            self.ball.dy = self.ball.dy * 1.02

            break
        end
    end

    if self.ball.y > VIRTUAL_HEIGHT then
        self.health = self.health - 1

        gSounds['hurt']:play()

        if self.health == 0 then
            -- TODO: change state to high score screen
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score
            })
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()

    for k, brick in pairs(self.bricks) do
       brick:render()
    end

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
    
    renderScore(self.score)
    renderHearts(self.health)
end