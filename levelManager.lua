Player = require("player")
BossEnemy = require("BossEnemy")
local STI = require("sti")

local levelManager = {}
function levelManager:load()
    self.currentLevel = 1
    self.level1 = STI("levels/level1.lua", {"box2d"})
    World = love.physics.newWorld(0, 1500, false)
    World:setCallbacks(OnEnterCollision, OnExitCollision)
    self.level1:box2d_init(World)
    self.level1.layers.ColLayer.visible = false
    self.gameOver = false
    self.first = true
    self.gameWon = love.audio.newSource("assets/sfx/playerWin.wav", "static")
    self.gameLost = love.audio.newSource("assets/sfx/playerLose.wav", "static")
    self.gameLost:setVolume(0.1)
    self.gameWon:setVolume(0.1)
end

function levelManager:update()
    if Player.health <= 0 then
        if self.first then
            self.first = false
            self.gameLost:play()
        end

        self.gameOver = true
    elseif BossEnemy.health <= 0 then
        if self.first then
            self.first = false
            self.gameWon:play()
        end
        self.gameOver = true
    end

end

return levelManager
