Brick = Class{}

function Brick:init(x, y)
    self.x = x
    self.y = y

    self.width = 32
    self.height = 16

    self.color = 0
    self.tier = 1

    -- used to determine whether this brick should be rendered
    self.inPlay = true
end

function Brick:hit()
    gSounds['brick-hit-2']:play()

    self.inPlay = false
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['bricks'][((self.color*4) + self.tier)], self.x, self.y)
    end
end