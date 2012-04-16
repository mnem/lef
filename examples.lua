------------------------------------------------------------------------------
-- This example assumes you are using the love framework (http://love2d.org/)
-- for the sake of convenience. The code will be similar for other frameworks.
------------------------------------------------------------------------------

-- Load the module
local lef = require 'nah.lef'

----------------------------------------
-- Register some components
lef.registerComponentFactory('position', function() return {x = 0, y = 0} end )
lef.registerComponentFactory('renderable', function() return {image = nil} end )

----------------------------------------
-- Create some systems
lef.addSystem('render', 'draw images', function(entities)
    for i, entity in ipairs(entities) do
        local pos, img = lef.entityComponents(entity, 'position', 'renderable')
        love.graphics.draw(img.image, pos.x, pos.y)
    end
end, 'position', 'renderable')

lef.addSystem('logic', 'follow mouse', function(entities)
    for i, entity in ipairs(entities) do
        local pos = lef.entityComponents(entity, 'position')
        pos.x = love.mouse.getX()
        pos.y = love.mouse.getY()
    end
end, 'position', 'active cursor')

----------------------------------------
-- Update the systems
function love.update()
    lef.updateSystem('logic')
end

function love.draw()
    lef.updateSystem('render')
end

----------------------------------------
-- Add some entites when it loads
function love.load()
    -- Create the entity that follows the cursor
    local cursimg = lef.addEntityComponents('cursor', 'renderable', 'active cursor', 'position')
    cursimg.image = love.graphics.newImage('thing.png')

    -- Place some other random entites which will be rendered but
    -- will not follow the cursor
    local img, pos
    for i=1, 100 do
        -- Using a new empty table for each entity because we don't really
        -- care what it is in this example.
        img, pos = lef.addEntityComponents({}, 'renderable', 'position')
        img.image = cursimg.image
        pos.x = 800 * math.random()
        pos.y = 600 * math.random()
    end
end

------------------------------------------------------------------------
-- Example of running the unit tests -----------------------------------
------------------------------------------------------------------------
local lefTests = require 'nah.tests.lef'
lefTests.runAll()
lefTests.printResults()
