LevelMaker = Class{}

function LevelMaker:createMap()
    local bricks = {}
    
    local numRows = math.random(3, 6)
    local numCols = math.random(7, 12)

    for y = 1, numRows do
        for x = 1, numCols do
            brick = Brick(
                -- x coordinate
                (x-1)
                * 32
                + 8
                + (13 - numCols) * 16,
                -- y coordinate
                y * 16
            )
            table.insert(bricks, brick)
        end
    end

    return bricks
end