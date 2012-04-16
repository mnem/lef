------------------------------------------------------------------------------
-- This file defines some unit tests for the lef entity framework.
--
-- To run them:
--
--    local leftests = require 'nah.tests.lef'
--    leftests.runAll()
--    leftests.printResults()
--
-- It assumes that left is in nah/lef.lua from the app base. If you have
-- moved it, update the M.runAll() function at the bottom of the file.
------------------------------------------------------------------------------

-- Module exports
local M = {}

------------------------------------------------------------------------------
-- Results -------------------------------------------------------------------
------------------------------------------------------------------------------
M.results = {}

local function logResult(event)
    table.insert(M.results, event)
end

function M.printResults()
    for i, result in ipairs(M.results) do
        local pass = result.pass and 'PASS' or 'FAIL'
        print(i, pass, result.message)
    end
end

------------------------------------------------------------------------------
-- Assertions  ---------------------------------------------------------------
------------------------------------------------------------------------------
local function success(message)
    logResult({ pass = true, message = message })
end

local function fail(message)
    logResult({ pass = false, message = message })
    error(message, 3)
end

local function assertEqual(message, expect, actual, failMessage)
    if expect == actual then
        success("PASS: " .. message)
    else
        failMessage = failMessage or ''
        expect = expect or 'nil'
        actual = actual or 'nil'
        fail("FAIL: " .. message .. " - " .. failMessage .. " Found " .. actual .. " expected " .. expect)
    end
end

------------------------------------------------------------------------------
-- Unit Tests ----------------------------------------------------------------
------------------------------------------------------------------------------
local T = {}

function T.testNoIntialSystems(lef)
    assertEqual('checking total systems', 0, lef.systemCount())
end

function T.testAddNilSystem(lef)
    lef.addSystem('testGroup', 'testSystem', nil)
    assertEqual('checking total systems', 0, lef.systemCount())
end

function T.testAddNilNameSystem(lef)
    lef.addSystem('testGroup', nil, function(e) end)
    assertEqual('checking total systems', 0, lef.systemCount())
end

function T.testAddNilGroupSystem(lef)
    lef.addSystem(nil, 'testSystem', function(e) end)
    assertEqual('checking total systems', 0, lef.systemCount())
end

function T.testAddOneSystem(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking systems in group', 1, groupCount.testGroup)
end

function T.testAddDuplicateSystem(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking systems in group', 1, groupCount.testGroup)

    lef.addSystem('testGroup', 'testSystem', function(e) end)

    count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking systems in group', 1, groupCount.testGroup)
end

function T.testAddTwoSystemsToOneGroup(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)
    lef.addSystem('testGroup', 'testSystem2', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 2, count)
    assertEqual('checking systems in group', 2, groupCount.testGroup)
end

function T.testAddTwoSystemsToTwoGroups(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)
    lef.addSystem('testGroup2', 'testSystem', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 2, count)
    assertEqual('checking systems in group 1', 1, groupCount.testGroup)
    assertEqual('checking systems in group 2', 1, groupCount.testGroup2)
end

function T.testAddThreeSystemsToTwoGroups(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)
    lef.addSystem('testGroup2', 'testSystem', function(e) end)
    lef.addSystem('testGroup2', 'testSystem2', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 3, count)
    assertEqual('checking systems in group 1', 1, groupCount.testGroup)
    assertEqual('checking systems in group 2', 2, groupCount.testGroup2)
end

function T.testUpdateOneSpecificSystem(lef)
    local system1UpdateCount = 0
    local system2UpdateCount = 0
    local system3UpdateCount = 0

    lef.addSystem('testGroup', 'testSystem1', function(e) system1UpdateCount = system1UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem2', function(e) system2UpdateCount = system2UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem3', function(e) system3UpdateCount = system3UpdateCount + 1 end)

    lef.updateSystem('testGroup', 'testSystem1')

    assertEqual('checking system 1 updates', 1, system1UpdateCount)
    assertEqual('checking system 2 updates', 0, system2UpdateCount)
    assertEqual('checking system 3 updates', 0, system3UpdateCount)

    lef.updateSystem('testGroup', 'testSystem1')

    assertEqual('checking system 1 updates', 2, system1UpdateCount)
    assertEqual('checking system 2 updates', 0, system2UpdateCount)
    assertEqual('checking system 3 updates', 0, system3UpdateCount)
end

function T.testUpdateOneGroup(lef)
    local system1UpdateCount = 0
    local system2UpdateCount = 0
    local system3UpdateCount = 0

    lef.addSystem('testGroup', 'testSystem1', function(e) system1UpdateCount = system1UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem2', function(e) system2UpdateCount = system2UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem3', function(e) system3UpdateCount = system3UpdateCount + 1 end)

    lef.updateSystem('testGroup')

    assertEqual('checking system 1 updates', 1, system1UpdateCount)
    assertEqual('checking system 2 updates', 1, system2UpdateCount)
    assertEqual('checking system 3 updates', 1, system3UpdateCount)

    lef.updateSystem('testGroup')

    assertEqual('checking system 1 updates', 2, system1UpdateCount)
    assertEqual('checking system 2 updates', 2, system2UpdateCount)
    assertEqual('checking system 3 updates', 2, system3UpdateCount)
end

function T.testUpdateOneSpecificGroup(lef)
    local system1UpdateCount = 0
    local system2UpdateCount = 0
    local system3UpdateCount = 0

    lef.addSystem('testGroup', 'testSystem1', function(e) system1UpdateCount = system1UpdateCount + 1 end)
    lef.addSystem('testGroup1', 'testSystem2', function(e) system2UpdateCount = system2UpdateCount + 1 end)
    lef.addSystem('testGroup1', 'testSystem3', function(e) system3UpdateCount = system3UpdateCount + 1 end)

    lef.updateSystem('testGroup1')

    assertEqual('checking system 1 updates', 0, system1UpdateCount)
    assertEqual('checking system 2 updates', 1, system2UpdateCount)
    assertEqual('checking system 3 updates', 1, system3UpdateCount)

    lef.updateSystem('testGroup1')

    assertEqual('checking system 1 updates', 0, system1UpdateCount)
    assertEqual('checking system 2 updates', 2, system2UpdateCount)
    assertEqual('checking system 3 updates', 2, system3UpdateCount)
end

function T.testUpdateNonExistentGroup(lef)
    local system1UpdateCount = 0
    local system2UpdateCount = 0
    local system3UpdateCount = 0

    lef.addSystem('testGroup', 'testSystem1', function(e) system1UpdateCount = system1UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem2', function(e) system2UpdateCount = system2UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem3', function(e) system3UpdateCount = system3UpdateCount + 1 end)

    lef.updateSystem('dont_exist')

    assertEqual('checking system 1 updates', 0, system1UpdateCount)
    assertEqual('checking system 2 updates', 0, system2UpdateCount)
    assertEqual('checking system 3 updates', 0, system3UpdateCount)
end


function T.testUpdateNonExistentSystem(lef)
    local system1UpdateCount = 0
    local system2UpdateCount = 0
    local system3UpdateCount = 0

    lef.addSystem('testGroup', 'testSystem1', function(e) system1UpdateCount = system1UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem2', function(e) system2UpdateCount = system2UpdateCount + 1 end)
    lef.addSystem('testGroup', 'testSystem3', function(e) system3UpdateCount = system3UpdateCount + 1 end)

    lef.updateSystem('testGroup', 'dont_exist')

    assertEqual('checking system 1 updates', 0, system1UpdateCount)
    assertEqual('checking system 2 updates', 0, system2UpdateCount)
    assertEqual('checking system 3 updates', 0, system3UpdateCount)
end

function T.testAddingAndRemovingOneSystem(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking total system group count', 1, groupCount.testGroup)

    lef.removeSystem('testGroup', 'testSystem')

    count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 0, count)
    assertEqual('checking total system group count', 0, groupCount.testGroup)
end

function T.testRemovingOneUniqueSystem(lef)
    lef.addSystem('testGroup', 'testSystem1', function(e) end)
    lef.addSystem('testGroup', 'testSystem2', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 2, count)
    assertEqual('checking total system group count', 2, groupCount.testGroup)

    lef.removeSystem('testGroup', 'testSystem1')

    count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking total system group count', 1, groupCount.testGroup)
end

function T.testRemovingSystemGroup(lef)
    lef.addSystem('testGroup', 'testSystem1', function(e) end)
    lef.addSystem('testGroup', 'testSystem2', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 2, count)
    assertEqual('checking total system group count', 2, groupCount.testGroup)

    lef.removeSystem('testGroup')

    count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 0, count)
    assertEqual('checking total system group count', nil, groupCount.testGroup)
end

function T.testRemovingUniqueSystemGroup(lef)
    lef.addSystem('testGroup1', 'testSystem1', function(e) end)
    lef.addSystem('testGroup1', 'testSystem2', function(e) end)
    lef.addSystem('testGroup2', 'testSystem3', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 3, count)
    assertEqual('checking total system group 1 count', 2, groupCount.testGroup1)
    assertEqual('checking total system group 2 count', 1, groupCount.testGroup2)

    lef.removeSystem('testGroup1')

    count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking total system group 1 count', nil, groupCount.testGroup1)
    assertEqual('checking total system group 2 count', 1, groupCount.testGroup2)
end

function T.testRemovingNonExistantSystem(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking total system group count', 1, groupCount.testGroup)

    lef.removeSystem('testGroup', 'dont_exist')

    count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking total system group count', 1, groupCount.testGroup)
end

function T.testRemovingNonExistantSystemGroup(lef)
    lef.addSystem('testGroup', 'testSystem', function(e) end)

    local count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking total system group count', 1, groupCount.testGroup)

    lef.removeSystem('dont_exist')

    count, groupCount = lef.systemCount()
    assertEqual('checking total systems', 1, count)
    assertEqual('checking total system group count', 1, groupCount.testGroup)
end

function T.testNoIntialComponentFactories(lef)
    assertEqual('checking number of component factories', 0, lef.componentFactoryCount())
end

function T.testAddingOneComponentFactory(lef)
    lef.registerComponentFactory('testFactory', function(e) end)
    assertEqual('checking number of component factories', 1, lef.componentFactoryCount())
end

function T.testAddingDuplicatComponentFactory(lef)
    lef.registerComponentFactory('testFactory', function(e) end)
    assertEqual('checking number of component factories', 1, lef.componentFactoryCount())
    lef.registerComponentFactory('testFactory', function(e) end)
    assertEqual('checking number of component factories', 1, lef.componentFactoryCount())
end

function T.testNoIntialEntites(lef)
    assertEqual('checking number of entities', 0, lef.entityCount())
end

function T.testAddingNilEntity(lef)
    lef.addEntityComponents(nil)
    assertEqual('checking number of entities', 0, lef.entityCount())
end

function T.testAddingOneEntity(lef)
    local entity = {}
    lef.addEntityComponents(entity)
    assertEqual('checking number of entities', 1, lef.entityCount())
end

function T.testGetNonExistentEntityComponent(lef)
    local entity = {}
    lef.addEntityComponents(entity)
    local ca = lef.entityComponents(entity, 'CA')
    assertEqual('checking number of entities', 1, lef.entityCount())
    assertEqual('checking component ca', nil, ca)
end

function T.testAddingOneEntityComponent(lef)
    local entity = {}
    lef.addEntityComponents(entity, 'CA')
    local ca, cb = lef.entityComponents(entity, 'CA', 'CB')
    assertEqual('checking number of entities', 1, lef.entityCount())
    assertEqual('checking component ca', '__placeholder "CA"', ca)
    assertEqual('checking component cb', nil, cb)
end

function T.testAddingDuplicateEntity(lef)
    local entity = {}
    lef.addEntityComponents(entity)
    assertEqual('checking number of entities', 1, lef.entityCount())

    lef.addEntityComponents(entity)
    assertEqual('checking number of entities', 1, lef.entityCount())
end

function T.testAddingTwoEntities(lef)
    local entityA = {}
    local entityB = {}
    lef.addEntityComponents(entityA)
    lef.addEntityComponents(entityB)
    assertEqual('checking number of entities', 2, lef.entityCount())
end

function T.testRemovingOneEntity(lef)
    local entity = {}
    lef.addEntityComponents(entity)
    assertEqual('checking number of entities', 1, lef.entityCount())

    lef.destroyEntity(entity)
    assertEqual('checking number of entities', 0, lef.entityCount())
end

function T.testRemovingOneEntityFromTwo(lef)
    local entityA = {}
    local entityB = {}
    lef.addEntityComponents(entityA, 'CA')
    lef.addEntityComponents(entityB, 'CB')
    assertEqual('checking number of entities', 2, lef.entityCount())

    lef.destroyEntity(entityA)
    assertEqual('checking number of entities', 1, lef.entityCount())

    lef.destroyEntity(entityA)
    assertEqual('checking number of entities', 1, lef.entityCount())
end


local function countComponentFactory()
    return { count = 0 }
end

function T.testOneEntityAddedToSystem(lef)
    -- Setup
    local entity = {}
    local function updateCountIncrementerSystem(entities)
        for i, entity in ipairs(entities) do
            local countComponent = lef.entityComponents(entity, 'countComponent')
            countComponent.count = countComponent.count + 1
        end
    end
    lef.addSystem('testGroup', 'testSystem', updateCountIncrementerSystem, 'countComponent')
    lef.registerComponentFactory('countComponent', countComponentFactory)
    lef.addEntityComponents(entity, 'countComponent')
    assertEqual('checking number of entities', 1, lef.entityCount())
    local cc = lef.entityComponents(entity, 'countComponent')
    assertEqual('checking update count', 0, cc.count)

    -- Tell the system to update
    lef.updateSystem('testGroup', 'testSystem')
    cc = lef.entityComponents(entity, 'countComponent')
    assertEqual('checking update count', 1, cc.count)
end

function T.testTwoEntitiesAddedToSystemOnlyOneUpdates(lef)
    -- Setup
    local entityA = {}
    local entityB = {}
    local function updateCountIncrementerSystem(entities)
        for i, entity in ipairs(entities) do
            local countComponent = lef.entityComponents(entity, 'countComponent')
            countComponent.count = countComponent.count + 1
        end
    end
    lef.addSystem('testGroup', 'testSystem', updateCountIncrementerSystem, 'countComponent')
    lef.registerComponentFactory('countComponent', countComponentFactory)
    lef.addEntityComponents(entityA, 'countComponent')
    lef.addEntityComponents(entityB)
    assertEqual('checking number of entities', 2, lef.entityCount())
    local ccA = lef.entityComponents(entityA, 'countComponent')
    local ccB = lef.entityComponents(entityB, 'countComponent')
    assertEqual('checking update count A', 0, ccA.count)
    assertEqual('checking update count B', nil, ccB)

    -- Tell the system to update
    lef.updateSystem('testGroup', 'testSystem')

    ccA = lef.entityComponents(entityA, 'countComponent')
    ccB = lef.entityComponents(entityB, 'countComponent')
    assertEqual('checking update count A', 1, ccA.count)
    assertEqual('checking update count B', nil, ccB)
end

function T.testTwoEntitiesAddedToSystemBothUpdate(lef)
    -- Setup
    local entityA = {}
    local entityB = {}
    local function updateCountIncrementerSystem(entities)
        for i, entity in ipairs(entities) do
            local countComponent = lef.entityComponents(entity, 'countComponent')
            countComponent.count = countComponent.count + 1
        end
    end
    lef.addSystem('testGroup', 'testSystem', updateCountIncrementerSystem, 'countComponent')
    lef.registerComponentFactory('countComponent', countComponentFactory)
    lef.addEntityComponents(entityA, 'countComponent')
    lef.addEntityComponents(entityB, 'countComponent')
    assertEqual('checking number of entities', 2, lef.entityCount())
    local ccA = lef.entityComponents(entityA, 'countComponent')
    local ccB = lef.entityComponents(entityB, 'countComponent')
    assertEqual('checking update count A', 0, ccA.count)
    assertEqual('checking update count B', 0, ccB.count)

    -- Tell the system to update
    lef.updateSystem('testGroup', 'testSystem')

    ccA = lef.entityComponents(entityA, 'countComponent')
    ccB = lef.entityComponents(entityB, 'countComponent')
    assertEqual('checking update count A', 1, ccA.count)
    assertEqual('checking update count B', 1, ccB.count)
end

function T.testEntityAddedToSystemAfterInitialAdd(lef)
    -- Setup
    local entityA = {}
    lef.addSystem('testGroup', 'testSystem', function() end, 'C')
    lef.addEntityComponents(entityA)
    assertEqual('checking number of entities', 1, lef.entityCount())

    local c = lef.entityComponents(entityA, 'C')
    assertEqual('checking component', nil, c)
    local entitiesCount = lef.systemEntityCount()
    assertEqual('checking system entities', 0, entitiesCount.testGroup.testSystem)

    -- Add the component to the entity
    lef.addEntityComponents(entityA, 'C')
    c = lef.entityComponents(entityA, 'C')
    assertEqual('checking component', '__placeholder "C"', c)
    entitiesCount = lef.systemEntityCount()
    assertEqual('checking system entities', 1, entitiesCount.testGroup.testSystem)
end

function T.testEntityAddedToNewSystem(lef)
    -- Setup
    local entityA = {}
    lef.addEntityComponents(entityA, 'C')
    assertEqual('checking number of entities', 1, lef.entityCount())

    lef.addSystem('testGroup', 'testSystem', function() end, 'C')

    local entitiesCount = lef.systemEntityCount()
    assertEqual('checking system entities', 1, entitiesCount.testGroup.testSystem)
end

function T.testEntityRemovedFromSystemAfterInitialAdd(lef)
    -- Setup
    local entityA = {}
    lef.addSystem('testGroup', 'testSystem', function() end, 'C')
    lef.addEntityComponents(entityA, 'C')
    assertEqual('checking number of entities', 1, lef.entityCount())

    local c = lef.entityComponents(entityA, 'C')
    assertEqual('checking component', '__placeholder "C"', c)
    local entitiesCount = lef.systemEntityCount()
    assertEqual('checking system entities', 1, entitiesCount.testGroup.testSystem)

    -- Add the component to the entity
    lef.removeEntityComponents(entityA, 'C')
    c = lef.entityComponents(entityA, 'C')
    assertEqual('checking component', nil, c)
    entitiesCount = lef.systemEntityCount()
    assertEqual('checking system entities', 0, entitiesCount.testGroup.testSystem)
end

function T.testEntityPlaceholderComponentUpdatedWithReal(lef)
    -- Setup
    local entityA = {}
    lef.addEntityComponents(entityA, 'C')
    assertEqual('checking number of entities', 1, lef.entityCount())

    local c = lef.entityComponents(entityA, 'C')
    assertEqual('checking component', '__placeholder "C"', c)

    lef.registerComponentFactory('C', countComponentFactory)

    c = lef.entityComponents(entityA, 'C')
    assertEqual('checking component', 0, c.count)
end

function T.testFetchAllEntitiesWithComponent(lef)
    -- Setup
    lef.addEntityComponents({}, 'A')
    lef.addEntityComponents({}, 'A', 'B')
    lef.addEntityComponents({}, 'A', 'C')
    lef.addEntityComponents({}, 'A', 'C')
    assertEqual('checking number of entities', 4, lef.entityCount())

    assertEqual('checking entity query', 4, #lef.entitiesWithComponents('A'))
    assertEqual('checking entity query', 1, #lef.entitiesWithComponents('B'))
    assertEqual('checking entity query', 2, #lef.entitiesWithComponents('C'))
    assertEqual('checking entity query', 0, #lef.entitiesWithComponents('B', 'C'))
    assertEqual('checking entity query', 1, #lef.entitiesWithComponents('B', 'A'))
    assertEqual('checking entity query', 2, #lef.entitiesWithComponents('C', 'A'))
end
------------------------------------------------------------------------------
-- Runner --------------------------------------------------------------------
------------------------------------------------------------------------------
function M.runAll()
    print('Running tests...')

    for name, test in pairs(T) do
        -- Force load/reload of package
        package.loaded['nah.lef'] = nil
        local lef = require 'nah.lef'

        lef.treatWarningsAsErrors = false
        lef.supressWarningTraceback = true
        print('  ' .. name)
        test(lef)
    end

    return results
end

return M
