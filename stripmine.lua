-- Initialize position and facing direction
local x, y, z, direction = 0, 0, 0, "north"
local savedX, savedY, savedZ, savedDirection = nil, nil, nil, nil  -- Storage for return position
local distance = 0 --distance moved
local strip = 0 --strip #

local fuel = turtle.getFuelLevel()
--------------------------------

function getfuel()
    fuel = turtle.getFuelLevel()
    while fuel < 4000 then 
        turtle.select(1)
        turtle.refuel()
        fuel = turtle.getFuelLevel()
    end
end

function store()

    turnLeft()
    turnLeft()
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
      end

    turtle.select(1) --fuel
    turtle.suckDown()

    turtle.select(2) --torches
    turtle.suckUp()

    turnLeft()
    turtle.select(3) --building material
    turtle.suck()
    turnLeft()
end


-- Load saved position from file
function loadPosition()
    if fs.exists("position.txt") then
        local file = fs.open("position.txt", "r")
        local line = file.readLine()
        file.close()

        local newX, newY, newZ, newDir = line:match("([^,]+),([^,]+),([^,]+),([^,]+)")
        return tonumber(newX), tonumber(newY), tonumber(newZ), newDir
    end
    return 0, 0, 0, "north"
end

-- Save position and direction to file
function savePosition()
    local file = fs.open("position.txt", "w")
    file.writeLine(x .. "," .. y .. "," .. z .. "," .. direction)
    file.close()
end

-- Movement functions
function moveForward()
    if direction == "north" then z = z - 1
    elseif direction == "south" then z = z + 1
    elseif direction == "east" then x = x + 1
    elseif direction == "west" then x = x - 1
    end
    turtle.forward()
    savePosition()
    distance = distance + 1
    fuel = turtle.getFuelLevel
    if fuel < 4000 then returnHome() end
end

function moveUp()
    y = y + 1
    turtle.up()
    savePosition()
end

function moveDown()
    y = y - 1
    turtle.down()
    savePosition()
end

-- Track turns
function turnLeft()
    local directions = {north="west", west="south", south="east", east="north"}
    direction = directions[direction]
    turtle.turnLeft()
    savePosition()
end

function turnRight()
    local directions = {north="east", east="south", south="west", west="north"}
    direction = directions[direction]
    turtle.turnRight()
    savePosition()
end

-- Save position before returning home
function saveReturnPosition()
    savedX, savedY, savedZ, savedDirection = x, y, z, direction
end

-- Return home
function returnHome()
    saveReturnPosition()  -- Save current position before leaving
    while x > 0 do turnLeft(); moveForward() end
    while x < 0 do turnRight(); moveForward() end
    while z > 0 do turnRight(); moveForward() end
    while z < 0 do turnLeft(); moveForward() end
    while y > 0 do moveDown() end
    while y < 0 do moveUp() end
    print("Returned home!")
    store()
    getfuel()
    if strip < 32 then returnToPrevious() else turnLeft(); turnLeft(); turnLeft(); turnLeft(); end
    
end

-- Return to previous position
function returnToPrevious()
    if savedX and savedY and savedZ then
        while y < savedY do moveUp() end
        while y > savedY do moveDown() end
        while x < savedX do turnRight(); moveForward() end
        while x > savedX do turnLeft(); moveForward() end
        while z < savedZ do turnRight(); moveForward() end
        while z > savedZ do turnLeft(); moveForward() end
        direction = savedDirection  -- Restore facing direction
        print("Returned to previous position!")
    else
        print("No previous position saved.")
    end
end

function minestrip()
    while strip < 32
    
        if distance < 160 then
            turtle.dig()
            moveForward()
            turnLeft()
            turtle.dig()
            turnLeft()
            turnLeft()
            turtle.dig()
            turnLeft()
            turtle.digUp()
            turtle.digDown()
            if y % 2 == 0 then
                if turtle.detectDown() then
                    turtle.select(3)
                    turtle.placeDown()
                end 
            
            else
                    if distance % 10 == 0  then
                        if turtle.detectDown() then
                            turtle.select(2)
                            turtle.placeDown()
                        end
                    end
            end
        else 
            if y % 2 == 0 then
                turtle.digUp()
                moveUp()
                turnLeft()
                turnLeft()
                distance = 0
            else
                    turtle.digDown()
                    moveDown()
                    turnLeft()
                    turtle.dig()
                    moveForward()
                    turtle.dig()
                    moveForward()
                    turtle.dig()
                    moveForward()
                    turtle.dig()
                    moveForward()
                    turtle.dig()
                    moveForward()
                    turtle.dig()
                    moveForward()
                    turtle.dig()
                    turnRight()
                    distance = 0
                    strip = strip + 1
                end
            end
        end
    end

    returnHome()
end




-----------------------------------------------------
-- Initialize position and direction on startup
x, y, z, direction = loadPosition()
getfuel()
minestrip()