local Player = require("player")
local BossEnemy = require("BossEnemy")
local levelManager = require("levelManager")

local UI = {}

function UI:load()
    self.PlayerBar = {}
    self.PlayerBar.posX = Player.posX
    self.PlayerBar.posY = Player.posY
    self.PlayerBar.score = 100

    self.enemyBar = {}
    self.enemyBar.posX = BossEnemy.posX
    self.enemyBar.posY = BossEnemy.posY
    self.enemyBar.score = 100

    self.fontT = love.graphics.newFont("assets/Attack Of Monster.ttf", 60)
    self.fontL = love.graphics.newFont("assets/Attack Of Monster.ttf", 200)

    self.timeSpent = 12
    self.levelMaxTime = 60
    self.levelScore = 500

end

function UI:update(deltaTime)
    self.enemyBar.posX = BossEnemy.posX - 130
    self.enemyBar.posY = BossEnemy.posY - 250

    self.PlayerBar.posX = Player.posX - 130
    self.PlayerBar.posY = Player.posY - 150

    self.timeSpent = self.timeSpent + deltaTime
    if levelManager.gameOver then
        return
    end
    self.score = math.max(0, self.levelMaxTime - self.timeSpent) * self.levelScore

end

function UI:draw()

    love.graphics.setFont(self.fontT)
    love.graphics.setColor(255 / 255, 165 / 255, 0 / 255, 255)
    love.graphics.print("Bonus Score : " .. math.floor(self.score), love.graphics.getWidth() / 2.5, 30)

    if levelManager.gameOver then
        love.graphics.setFont(self.fontL)

        if BossEnemy.health <= 0 then
            love.graphics.setColor(255 / 255, 255 / 255, 0 / 255, 255)
            love.graphics.print("Player Wins", love.graphics.getWidth() / 4, 400)
        else
            love.graphics.setColor(255 / 255, 0 / 255, 0 / 255, 255)
            love.graphics.print("Player Lose", love.graphics.getWidth() / 4, 400)
        end
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 255)
        return
    end

    love.graphics.setColor(124 / 255, (BossEnemy.health) / 255, 0 / 255, 255)
    love.graphics.rectangle("fill", self.enemyBar.posX, self.enemyBar.posY, (BossEnemy.health), 30)

    love.graphics.setColor(124 / 255, Player.health / 255, 0 / 255, 255)
    love.graphics.rectangle("fill", self.PlayerBar.posX, self.PlayerBar.posY, (Player.health), 10)
    love.graphics.setColor(1, 1, 1, 1)
end

return UI
