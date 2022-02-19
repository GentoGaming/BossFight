
local Bullet = require("Bullet")

local BossEnemy = {}

function BossEnemy:load()

    self.posX = 1600
    self.posY = 600

    self.startPositionX = self.posX
    self.startPositionY = self.posY

    self.width = 443
    self.height = 302

    self.health = 255

    self.physics = {}
    self.timerShoot = 10
    self.physics.body = love.physics.newBody(World, self.posX, self.posY, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width / 2 , self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setMass(145)

    self.animations = {}
    self.flysprite = love.graphics.newImage("assets/enemy/enemyFlySpriteSheet.png")
    self.flyGrid = anim8.newGrid(self.width,self.height,self.flysprite:getWidth(),self.flysprite:getHeight())
    self.animations.fly = anim8.newAnimation(self.flyGrid('1-2',1),0.15)


    self.shootsprite = love.graphics.newImage("assets/enemy/enemyShootingSpriteSheet.png")
    self.shootGrid = anim8.newGrid(self.width,self.height,self.shootsprite:getWidth(),self.shootsprite:getHeight())
    self.animations.shoot = anim8.newAnimation(self.shootGrid(1,'1-5'),0.15)


    self.currentAnimation = self.animations.fly
    self.currentSprite = self.flysprite
    self.randomShootingInterval = math.random(1)
    self.bAnimationReversed = true
    self.currentAnimation:reverse(self.bAnimationReversed)
    
    self.randomTimeOffset = 100
end

function BossEnemy:textureFollowPhysicsBody()
    self.posX,self.posY = self.physics.body:getPosition()

end

function BossEnemy:setDamage(damage)
    self.health = self.health - damage
end

function BossEnemy:update(deltaTime)
    self.currentAnimation:update(deltaTime)
    self:textureFollowPhysicsBody()

    if(self.currentAnimation == self.animations.shoot) then
    if self.timerShoot > 0.2 then
        self.currentAnimation = self.animations.fly
        self.currentSprite = self.flysprite
        self.currentAnimation:reverse(self.bAnimationReversed)
    end
    end


    if(self.bCoinDrop) then
      -- Coin.newCoin(self.posX,self.posY)
       Coin.newCoin(1000,300)

      self.bCoinDrop = false
    end

    local leftRightNum = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
    leftRightNum = leftRightNum * 50
    if(self.posX > self.startPositionX + 10 and leftRightNum >0) then
        leftRightNum = -leftRightNum 
    elseif (self.posX < self.startPositionX - 10 and leftRightNum <0)then
        leftRightNum = -leftRightNum 
    end
    if self.posY > self.startPositionY - 60 then
    self.physics.body:applyForce(leftRightNum* 100,-235000)   
    end
    self.timerShoot = self.timerShoot + deltaTime
   
    if self.timerShoot > self.randomShootingInterval then
        Bullet.newBullet(self,50,self.posX - 50 ,self.posY+ 100,true,0.5,"assets/enemy/enemyBulletSpriteSheet.png")
        self.timerShoot = 0
        self.currentAnimation = self.animations.shoot
        self.currentSprite = self.shootsprite
        self.currentAnimation:reverse(self.bAnimationReversed)
        self.randomShootingInterval = math.random(1.2)
    end

end
function BossEnemy:draw()
  self.currentAnimation:draw(self.currentSprite,self.posX - self.width / 2 ,self.posY - self.height / 2)
end


function BossEnemy:OnEnterCollision(firstfixture, otherFixture,hitResult)

end


return BossEnemy
