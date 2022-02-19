local STI = require("sti")

 anim8 = require 'lib/anim8'
local UI = require("UI")
local Bullet = require("Bullet")
Player = require("player")
BossEnemy = require("BossEnemy")

function love.load()
    Map = STI("levels/level1.lua", {"box2d"})
    World = love.physics.newWorld(0,1500,false)
    World:setCallbacks(OnEnterCollision, OnExitCollision)
    Map:box2d_init(World)
    Map.layers.ColLayer.visible = false
    background = love.graphics.newImage("assets/Background/BG.png")
    Player:load()
    BossEnemy:load()

    UI:load()


end

function love.update(deltaTime)
    World:update(deltaTime)
    Bullet.updateAll(deltaTime)
    Player:update(deltaTime)
    BossEnemy:update(deltaTime)
    UI:update(deltaTime)

end



function love.draw()
    love.graphics.draw(background)
    Map:draw(0,0,1,1)
    Player:draw()
    BossEnemy:draw()
    Bullet.drawAll()
    UI:draw()

end


function love.keypressed(keyCode)
    Player:keypressed(keyCode)
end



function OnEnterCollision(firstfixture, otherFixture,hitResult)
   if Bullet:OnEnterCollision(firstfixture, otherFixture,hitResult) then return end
    Player:OnEnterCollision(firstfixture, otherFixture,hitResult)
    BossEnemy:OnEnterCollision(firstfixture, otherFixture,hitResult)
end
