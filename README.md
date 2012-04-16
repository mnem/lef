## lef

Simple entity framework for lua. Written with [LÖVE][love] in mind, but will
probably for any lua implementation using lua 5.1 or above.

If you want a decent overview of entity frameworks and why they are
useful, have a read of these blog post by [Richard Lord][rl]:

- [What is an entity framework for game development?][rl_1]
- [Why use an entity framework for game development?][rl_2]

lef isn't as advanced as the frameworks mentioned in those articles,
but it's good enough to play around with in lua. I'll probably use it
in the next [Ludum Dare][ld] I play along with, so no doubt there will be
lots of changes made to this after that.

Here's a very simple example if you are using [LÖVE][love]. It creates
an image which follows the mouse cursor around.

```lua
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
    cursimg.image = love.graphics.newImage('sheep.png')

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
```

[rl]:    http://www.richardlord.net/blog
[rl_1]:  http://www.richardlord.net/blog/what-is-an-entity-framework
[rl]_2]: http://www.richardlord.net/blog/why-use-an-entity-framework
[ld]:    http://www.ludumdare.com/compo/
[love]:  http://love2d.org/
