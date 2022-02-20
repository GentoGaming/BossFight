local levelManager = require("levelManager")
local UI = require("UI")
local Bullet = require("Bullet")
local Bomb = require("Bomb")

function love.load()
    levelManager:load()
    background = love.graphics.newImage("assets/Background/BG.png")
    Player:load()
    BossEnemy:load()
    UI:load()
end

function love.update(deltaTime)
    World:update(deltaTime)
    UI:update(deltaTime)

    if levelManager.gameOver then
        return
    end

    Player:update(deltaTime)
    BossEnemy:update(deltaTime)
    levelManager:update()
    Bullet.updateAll(deltaTime)
    Bomb.updateAll(deltaTime)
end

function love.draw()
    love.graphics.draw(background)
    levelManager.level1:draw(0, 0, 1, 1)
    UI:draw()

    if levelManager.gameOver then
        return
    end

    Player:draw()
    BossEnemy:draw()
    Bullet.drawAll()
    Bomb.drawAll()
end

function love.keypressed(keyCode)
    Player:keypressed(keyCode)
end

function OnEnterCollision(firstfixture, otherFixture, hitResult)
    if Bomb:OnEnterCollision(firstfixture, otherFixture, hitResult) then
        return
    end
    if Bullet:OnEnterCollision(firstfixture, otherFixture, hitResult) then
        return
    end
    Player:OnEnterCollision(firstfixture, otherFixture, hitResult)
    BossEnemy:OnEnterCollision(firstfixture, otherFixture, hitResult)
end
