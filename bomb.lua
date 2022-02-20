local anim8 = require 'lib/anim8'

local Bomb = {}
Bomb.__index = Bomb
local AllBombs = {}

function Bomb.newBomb(owner, damage, posX, posY)
    local nBomb = setmetatable({}, Bomb)
    nBomb.bPendingRemove = false
    nBomb.posX = posX
    nBomb.posY = posY
    nBomb.Bombsprite = love.graphics.newImage("assets/Others/bombsmall.png")
    nBomb.width = nBomb.Bombsprite:getWidth()
    nBomb.height = nBomb.Bombsprite:getHeight()
    nBomb.damage = damage
    nBomb.bReversed = true
    nBomb.physics = {}
    nBomb.scale = 1
    if bReversed then
        nBomb.posX = posX - 20
    end
    nBomb.physics.body = love.physics.newBody(World, nBomb.posX, nBomb.posY, "dynamic")
    nBomb.physics.shape = love.physics.newCircleShape(5)
    nBomb.physics.fixture = love.physics.newFixture(nBomb.physics.body, nBomb.physics.shape)
    nBomb.physics.fixture:setSensor(false)
    nBomb.BombGrid = anim8.newGrid(nBomb.width, nBomb.height, nBomb.Bombsprite:getWidth(), nBomb.Bombsprite:getHeight())

    nBomb.animations = {}
    nBomb.animations.Bomb = anim8.newAnimation(nBomb.BombGrid(1, 1), 0.15)
    nBomb.animations.Bomb:reverse(bReversed)

    nBomb.explosionSprite = love.graphics.newImage("assets/Others/explosion_01_strip13.png")
    nBomb.explosionWidth = nBomb.explosionSprite:getWidth() / 13
    nBomb.explosionHeight = nBomb.explosionSprite:getHeight()
    nBomb.explosionGrid = anim8.newGrid(nBomb.explosionWidth, nBomb.explosionHeight, nBomb.explosionSprite:getWidth(),
        nBomb.explosionSprite:getHeight())
    nBomb.animations.explosion = anim8.newAnimation(nBomb.explosionGrid('1-13', 1), 0.1)

    nBomb.currentAnimation = nBomb.animations.Bomb
    nBomb.currentSprite = nBomb.Bombsprite

    nBomb.scoreValue = 10
    nBomb.owner = owner
    local forceRandom = math.random(5,20)
    nBomb.physics.body:applyForce(-forceRandom * 100, -20 * 100)
    nBomb.bShouldBlow = false
    nBomb.deathTimer = 0

    nBomb.explosionBomb = love.audio.newSource("assets/sfx/bomb.wav", "static")
    nBomb.explosionBomb:setVolume(0.05)
    table.insert(AllBombs, nBomb)
end

function Bomb.drawAll()
    for i, v in ipairs(AllBombs) do
        v:draw()
    end
end

function Bomb.updateAll(deltaTime)
    for i, v in ipairs(AllBombs) do
        v:update(deltaTime)
    end
end

function Bomb:remove()
    for i, v in ipairs(AllBombs) do
        if v.bPendingRemove and v == self then
            v.physics.body:destroy()
            Player:SetScore(v.scoreValue)
            table.remove(AllBombs, i)
        end
    end
end

function Bomb:remove()
    for i, v in ipairs(AllBombs) do
        if v.bPendingRemove and v == self and v.deathTimer < 0.1 * 12 and v.currentAnimation == v.animations.Bomb then
            v.physics.body:setActive(false)
            v.currentAnimation = v.animations.explosion
            v.currentSprite = v.explosionSprite
            v.width = v.explosionWidth
            v.height = v.explosionHeight
        elseif v.bPendingRemove and v == self and v.deathTimer > 0.1 * 12 then
            v.physics.body:destroy()
            v.explosionBomb:play()
            table.remove(AllBombs, i)
        end
    end
end

function Bomb:textureFollowPhysicsBody()
    self.posX, self.posY = self.physics.body:getPosition()
end

function Bomb:draw()
    self.currentAnimation:draw(self.currentSprite, self.posX - self.width / 2, self.posY - self.height / 2, nil,
        self.scale, self.scale)
end

function Bomb:update(deltaTime)
    self:textureFollowPhysicsBody()
    self.currentAnimation:update(deltaTime)
    self.deathTimer = self.deathTimer + deltaTime
    self:remove()

end

function Bomb:OnEnterCollision(firstfixture, otherFixture, hitResult)
    local first = false
    local second = false
    -- only 1 max 3 bombs is active a time 
    for i, v in ipairs(AllBombs) do
        if (firstfixture == v.physics.fixture) then
            first = true
        end
        if (otherFixture == v.physics.fixture) then
            second = true
        end
    end
    if first and second then
        return true
    end
    for i, v in ipairs(AllBombs) do
        --  if v.bPendingRemove then return end
        if (firstfixture == v.physics.fixture or otherFixture == v.physics.fixture) then
            if (firstfixture == v.owner.physics.fixture or otherFixture == v.owner.physics.fixture) then
                return true
            else
                v.bShouldBlow = true
                v.physics.body:setLinearVelocity(0, 0)

                if firstfixture == Player.physics.fixture or otherFixture == Player.physics.fixture and
                    not v.bPendingRemove then
                    Player:setDamage(v.damage)
                end
                v.bPendingRemove = true
                v.deathTimer = 0
                return true
            end
        end
    end
end

return Bomb
