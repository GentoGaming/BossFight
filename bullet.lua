local anim8 = require 'lib/anim8'

local Bullet = {}
Bullet.__index = Bullet
local AllBullets = {}

function Bullet.newBullet(owner, damage, posX, posY, bReversed, scale, spriteName)
    local nBullet = setmetatable({}, Bullet)
    nBullet.rotatingBulletprite = love.graphics.newImage(spriteName)
    nBullet.bPendingRemove = false
    nBullet.posX = posX
    nBullet.posY = posY
    nBullet.width = nBullet.rotatingBulletprite:getWidth() / 5
    nBullet.height = nBullet.rotatingBulletprite:getHeight()
    nBullet.damage = damage
    nBullet.bReversed = bReversed
    nBullet.physics = {}
    nBullet.scale = scale
    if bReversed then
        nBullet.posX = posX - 20
    end
    nBullet.physics.body = love.physics.newBody(World, nBullet.posX, nBullet.posY, "dynamic")
    nBullet.physics.shape = love.physics.newCircleShape(22)
    nBullet.physics.fixture = love.physics.newFixture(nBullet.physics.body, nBullet.physics.shape)
    nBullet.physics.fixture:setSensor(true)

    nBullet.animations = {}
    nBullet.rotatingBulletGrid = anim8.newGrid(nBullet.width, nBullet.height, nBullet.rotatingBulletprite:getWidth(),
        nBullet.rotatingBulletprite:getHeight())
    nBullet.animations.rotate = anim8.newAnimation(nBullet.rotatingBulletGrid('1-5', 1), 0.15)
    nBullet.animations.rotate:reverse(bReversed)
    nBullet.scoreValue = 10
    nBullet.owner = owner
    table.insert(AllBullets, nBullet)
end

function Bullet.drawAll()
    for i, v in ipairs(AllBullets) do
        v:draw()
    end
end

function Bullet.updateAll(deltaTime)
    for i, v in ipairs(AllBullets) do
        v:update(deltaTime)
    end
end

function Bullet:remove()
    for i, v in ipairs(AllBullets) do
        if v.bPendingRemove and v == self then
            v.physics.body:destroy()
            Player:SetScore(v.scoreValue)
            print(Player.score)
            table.remove(AllBullets, i)
        end
    end
end

function Bullet:remove()
    for i, v in ipairs(AllBullets) do
        if v.bPendingRemove and v == self then
            v.physics.body:destroy()
            table.remove(AllBullets, i)
        end
    end
end

function Bullet:textureFollowPhysicsBody()
    self.posX, self.posY = self.physics.body:getPosition()
end

function Bullet:draw()
    self.animations.rotate:draw(self.rotatingBulletprite, self.posX - self.width / 2, self.posY - self.height / 2, nil,
        self.scale, self.scale)
end

function Bullet:update(deltaTime)
    if self.bReversed then
        self.physics.body:setLinearVelocity(-1500, 0)
    else
        self.physics.body:setLinearVelocity(1500, 0)
    end
    self:textureFollowPhysicsBody()
    self.animations.rotate:update(deltaTime)
    self:remove()
end

function Bullet:OnEnterCollision(firstfixture, otherFixture, hitResult)
    for i, v in ipairs(AllBullets) do
        if (firstfixture == v.physics.fixture or otherFixture == v.physics.fixture) then
            if (firstfixture == v.owner.physics.fixture or otherFixture == v.owner.physics.fixture) then
                return true
            else
                if firstfixture == BossEnemy.physics.fixture or otherFixture == BossEnemy.physics.fixture then
                    BossEnemy:setDamage(v.damage)
                elseif firstfixture == Player.physics.fixture or otherFixture == Player.physics.fixture then
                    Player:setDamage(v.damage)
                end
                v.bPendingRemove = true
                return true
            end
        end
    end
end

return Bullet
