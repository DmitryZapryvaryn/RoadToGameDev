Bird = Class{}

local GRAVITY = 20
local ANTI_GRAVITY = -5

function Bird:init()
    self.image = love.graphics.newImage('bird.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.x = VIRTUAL_WIDTH / 3 - (self.width / 2)
    self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)

    self.dy = 0

    self.rotation = 0
end

function Bird:collides(pipe)
   if (self.x + 2)  + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH and
      (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
        return true
    end

    return false
end

function Bird:update(dt)
    self.dy = self.dy + GRAVITY * dt

    if love.keyboard.wasPressed('space') then
        self.dy = ANTI_GRAVITY
    end

    self.y = self.y + self.dy

    -- rotate bird according to its acceleration
    self.rotation = self.dy * 2
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y, math.rad(self.rotation))
end