PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_HEIGHT = 288
PIPE_WIDTH = 70

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}

    self.spawnTimer = 0
    self.spawnDelay = 2

    -- init our last recorded Y value for a gap placement to base other gaps
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20

    self.score = 0
end

function PlayState:update(dt)
    self.spawnTimer = self.spawnTimer + dt

    if self.spawnTimer > self.spawnDelay then
        local y =  math.max( -PIPE_HEIGHT + 20, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 80 - PIPE_HEIGHT))
        self.lastY = y

        table.insert(self.pipePairs, PipePair(y))

        self.spawnTimer = 0
        self.spawnDelay = math.random() + math.random(2, 5)
    end

    for k, pipePair in pairs(self.pipePairs) do
        
        if not pipePair.scored then
            if pipePair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pipePair.scored = true
            end
        end

        pipePair:update(dt)           
    end

    for k, pipePair in pairs(self.pipePairs) do
        if pipePair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    self.bird:update(dt)

    for k, pipePair in pairs(self.pipePairs) do
        for l, pipe in pairs(pipePair.pipes) do
            if self.bird:collides(pipe) then
                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end
    
    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end