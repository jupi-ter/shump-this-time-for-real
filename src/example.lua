-- example.lua - Demonstrates class system usage

local Class = require("class")

-- Define interfaces
local IDrawable = Class.interface("IDrawable", {"draw", "getZIndex"})
local IUpdatable = Class.interface("IUpdatable", {"update"})

-- Abstract base class
local Entity = Class:extend("Entity", {abstract = true})

-- Static constant (just use class table directly)
Entity.COLLISION_PADDING = 5

function Entity:init(x, y)
    self.x = x
    self.y = y
    self.health = 100
end

-- Abstract method - subclasses MUST implement this
Entity.takeDamage = Class.abstract

function Entity:isAlive()
    return self.health > 0
end

-- Concrete Player class implementing interfaces
local Player = Entity:extend("Player", {
    implements = {IDrawable, IUpdatable}
})

-- Static factory method
function Player.fromSaveData(data)
    return Player(data.x, data.y, data.name)
end

function Player:init(x, y, name)
    Player.super.init(self, x, y)  -- Call parent constructor
    self.name = name
    self.score = 0
end

function Player:takeDamage(amount)
    self.health = self.health - amount
    print(self.name .. " took " .. amount .. " damage! Health: " .. self.health)
end

-- Interface methods
function Player:draw()
    print("Drawing " .. self.name .. " at (" .. self.x .. ", " .. self.y .. ")")
end

function Player:getZIndex()
    return 10
end

function Player:update(dt)
    -- Player-specific update logic
    self.x = self.x + 1  -- Move right
end

-- Another concrete class
local Enemy = Entity:extend("Enemy", {
    implements = {IDrawable, IUpdatable}
})

function Enemy:init(x, y, enemyType)
    Enemy.super.init(self, x, y)
    self.enemyType = enemyType
end

function Enemy:takeDamage(amount)
    self.health = self.health - amount
    print(self.enemyType .. " enemy took " .. amount .. " damage!")
end

function Enemy:draw()
    print("Drawing " .. self.enemyType .. " enemy at (" .. self.x .. ", " .. self.y .. ")")
end

function Enemy:getZIndex()
    return 5
end

function Enemy:update(dt)
    -- Enemy AI
    self.x = self.x - 0.5  -- Move left
end

-- Usage demonstration
print("=== Creating Entities ===")
local player = Player(100, 200, "Hero")
local enemy = Enemy(300, 200, "Goblin")

-- Using static factory method
local savedPlayer = Player.fromSaveData({x = 50, y = 50, name = "LoadedHero"})

print("\n=== Type Checking ===")
print("player instanceof Entity:", instanceof(player, Entity))  -- true
print("player instanceof Player:", instanceof(player, Player))  -- true
print("player implements IDrawable:", implements(player, IDrawable))  -- true
print("enemy instanceof Player:", instanceof(enemy, Player))  -- false

print("\n=== Calling Methods ===")
player:draw()
enemy:draw()

print("\n=== Polymorphism ===")
local entities = {player, enemy, savedPlayer}
for _, entity in ipairs(entities) do
    entity:takeDamage(10)
    entity:update(0.016)
    entity:draw()
    print("Alive:", entity:isAlive())
    print()
end

print("\n=== Static Access ===")
print("Collision padding:", Entity.COLLISION_PADDING)

-- These would cause errors (uncomment to test):

-- Error: Cannot instantiate abstract class
-- local e = Entity(0, 0)

-- Error: Missing interface method
-- local BadClass = Entity:extend("BadClass", {implements = {IDrawable}})
-- function BadClass:takeDamage(amount) end
-- local bad = BadClass(0, 0)  -- Missing draw() and getZIndex()

-- Error: Missing abstract method implementation
-- local IncompleteClass = Entity:extend("IncompleteClass")
-- function IncompleteClass:init(x, y) IncompleteClass.super.init(self, x, y) end
-- local incomplete = IncompleteClass(0, 0)  -- Missing takeDamage()
