local Bullet = require("Bullet")
local Player = {}

function Player:load()
   
    self.posX = 100
    self.posY = 500
    
    self.width = 283
    self.height = 278

    self.maxSpeed = 500
    self.acceleration = 10000
    
    self.velocityX = 0
    self.velocityY = 90.82

    self.jumpForce = -1000
    self.bGrounded = false
 
    self.friction = 2000
    self.gravity = 2500

    self.physics = {}

    self.physics.body = love.physics.newBody(World, self.posX, self.posY, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width /2, self.height-30)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.health = 255

    self.score = 0

    -- Animations
    self.animations = {}
    
    self.walkSprite = love.graphics.newImage("assets/Player/walkSpriteSheet.png")
    self.idleSprite = love.graphics.newImage("assets/Player/idleSpriteSheet.png")
    self.jumpSprite = love.graphics.newImage("assets/Player/jumpSpriteSheet.png")
    self.shootSprite = love.graphics.newImage("assets/Player/shootSpriteSheet.png")

 
    
    self.walkGrid = anim8.newGrid(self.width,self.height,self.walkSprite:getWidth(),self.walkSprite:getHeight())
    self.idleGrid = anim8.newGrid(self.width,self.height,self.idleSprite:getWidth(),self.idleSprite:getHeight())
    self.jumpGrid = anim8.newGrid(self.width,self.height,self.idleSprite:getWidth(),self.jumpSprite:getHeight())
    self.shootGrid = anim8.newGrid(self.width,self.height,self.shootSprite:getWidth(),self.shootSprite:getHeight())


    self.animations.walk = anim8.newAnimation(self.walkGrid(1,'1-3',2,'1-3',3,'1-2'),0.15)
    self.animations.idle = anim8.newAnimation(self.idleGrid('1-3','1-3'),0.15)
    self.animations.jump = anim8.newAnimation(self.jumpGrid('1-3','1-3'),0.1)
    self.animations.shoot = anim8.newAnimation(self.shootGrid('1-3',1),0.3)

    self.animations.shootingTimer = 0.2
    self.animations.shootingTimeEnd = 0.1

    self.currentAnimation = self.animations.idle
    self.currentSprite = self.idleSprite
    self.bAnimationReversed = false

 end



function Player:update(deltaTime)
    self:textureFollowPhysicsBody()
    self:horizontalMovement(deltaTime)
    self:addGravity(deltaTime)
    self:addFriction(deltaTime) 
    self.currentAnimation:update(deltaTime)
    self.animations.shootingTimer = self.animations.shootingTimer + deltaTime
end


function Player:UpdateAnimation(animationName)
self.currentAnimation:reverse(self.bAnimationReversed)

if animationName == "shoot" then
    self.currentAnimation = self.animations.shoot
    self.currentSprite = self.shootSprite  
end

if (not self.bGrounded or self.animations.shootingTimer < self.animations.shootingTimeEnd) then return end

if animationName == "idle" then
    self.currentAnimation = self.animations.idle
    self.currentSprite = self.idleSprite  
elseif  animationName == "walk" then
    self.currentAnimation = self.animations.walk
    self.currentSprite = self.walkSprite  
elseif animationName == "jump" then
    self.currentAnimation = self.animations.jump
    self.currentSprite = self.jumpSprite  
end
end

function Player:addGravity(deltaTime)
    if(self.bGrounded ) then return end
self.velocityY = self.velocityY + self.gravity * deltaTime
end    

function Player:addFriction(deltaTime) 
    if(self.velocityX > 0) then
    self.velocityX = math.max(self.velocityX - (self.friction * deltaTime),0)    
    elseif(self.velocityX < 0) then
        self.velocityX = math.min(self.velocityX + (self.friction * deltaTime),0)     
    end
end


function Player:horizontalMovement(deltaTime)
    if (love.keyboard.isDown("a")) then
        self.bAnimationReversed = true
        self:UpdateAnimation("walk")
        self.velocityX = math.max(self.velocityX - (self.acceleration * deltaTime),-self.maxSpeed)    
    return

    end  
    
    if love.keyboard.isDown("d") then
        self.bAnimationReversed = false
        self:UpdateAnimation("walk")
        local tempVelocity = self.velocityX + (self.acceleration * deltaTime)
        self.velocityX = math.min(self.velocityX + (self.acceleration * deltaTime),self.maxSpeed)    
        return
    end

    self:UpdateAnimation("idle")

    end


function Player:textureFollowPhysicsBody()
self.posX,self.posY = self.physics.body:getPosition()
self.physics.body:setLinearVelocity(self.velocityX,self.velocityY)
end

function Player:keypressed(keyCode)
    if(keyCode == "w") then
    self:Jump()
    end
    if(keyCode == "space") then
        self:Shoot()
        self.animations.shootingTimer = 0
        self:UpdateAnimation("shoot")
    end
end

function Player:Jump()
if (not self.bGrounded) then return end
self:UpdateAnimation("jump")

self.velocityY = self.jumpForce
self.bGrounded = false
end

function Player:OnEnterCollision(firstfixture, otherFixture,hitResult)
if(self.bGrounded) then return end

local normalX,noramlY = hitResult:getNormal()
if(firstfixture == self.physics.fixture) then
if (noramlY > 0) then
self:groundPlayer()
end
elseif (otherFixture == self.physics.fixture) then
    if (noramlY < 0) then 
        self:groundPlayer()
    end
end
end

function Player:groundPlayer()
self.bGrounded = true
self.velocityY = 0
end

function Player:setDamage(damage)
    self.health = self.health - damage
end

function Player:Shoot()
    local posX = self.posX
    if not self.bAnimationReversed then
        posX = posX + 170
    end
    
    Bullet.newBullet(self,10,posX,self.posY+ 63,self.bAnimationReversed,0.25,"assets/player/bulletSpriteSheet.png")
end

function Player:draw()
    self.currentAnimation:draw(self.currentSprite,self.posX - self.width / 2 ,self.posY - self.height / 2)
end

return Player