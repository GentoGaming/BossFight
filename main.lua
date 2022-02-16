local STI = require("sti")
require("player")
anim8 = require 'lib/anim8'

function love.load()
    Map = STI("levels/level1.lua", {"box2d"})
    World = love.physics.newWorld(0, 0)
    World:setCallbacks(OnEnterCollision, OnExitCollision)
    Map:box2d_init(World)
    Map.layers.ColLayer.visible = false
    background = love.graphics.newImage("assets/Background/BG.png")
    Player:load()
end

function love.update(deltaTime)
    World:update(deltaTime)
    Player:update(deltaTime)
end


function love.draw()
    love.graphics.draw(background)
    Map:draw(0,0,1,1)
    Player:draw()
end


function love.keypressed(keyCode)
    Player:keypressed(keyCode)
end



function OnEnterCollision(firstfixture, otherFixture,hitResult)
    Player:OnEnterCollision(firstfixture, otherFixture,hitResult)
end

function OnExitCollision(firstfixture, otherFixture,hitResult)
    Player:OnExitCollision(firstfixture, otherFixture,hitResult)
end