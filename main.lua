RAILGUN_GROUP = {
  player  = -1,
  enemy   = 2,
  bullet  = 3,
}

require('ulits')

class = require('30log')
require('World')
require('Player')
require('Bullet')
require('Enemy')
require('Map')


local mouse = {x = 0, y = 0}
local edgePoint = {x = 0, y = 0}

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  love.graphics.setPointSize(2)
  world = World:new({mapPath = 'res/map/stage2'})
  player = Player:new()
  player.weapon = Gun:new()
  world:add(player)
  world.focus = player.pos
end

local num = 0

function love.update(dt)
  
  if player.alive then
    world:update(dt)
  end
  
  --[[
  --edgePoint = updateEdgePoint()
  ]]--
end

function love.draw()
  love.graphics.push('all')
  world:draw()
  love.graphics.pop()
  
  --love.graphics.print(love.timer.getFPS())
  --love.graphics.print(string.format("%.1f", player.pos.x)..','..string.format("%.1f", player.pos.y))
  --drawAimLine()
  if not player.alive then
    love.graphics.push('all')
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.print('Game Over', love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 2, 2, 37, 7)
    love.graphics.pop()
  else 
    if world.pause then
      love.graphics.push('all')
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print('Pause', love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 2, 2, 37, 7)
      love.graphics.pop()
    else
      local stats = love.graphics.getStats()
      love.graphics.push('all')
      love.graphics.print('HP:'.. player.hp .. '/100' .. ' | AMMO:' .. player.weapon.ammo .. '/' .. player.weapon.maxAmmo .. ' | Enemies:' .. world.enemyCount .. ' | FPS:' .. love.timer.getFPS() .. "\nDrawcalls: "..stats.drawcalls.."\nUsed VRAM: "..string.format("%.2f MB", stats.texturememory / 1024 / 1024), 0, 0)
      love.graphics.pop()
    end
  end
end

function love.keypressed(key, isRepeat)
  if key == 'escape' then
    world.pause = not world.pause
  end
  
  if key == 'g' then
    local x, y = world:mousePos()
    local grenade = Grenade:new(world.physics, x, y)
    world:add(grenade)
    grenade:explosive()
  end
end

function love.resize( w, h )
  if world.light then
    world.light:refreshScreenSize()
  end
end

--画瞄准线
local function drawAimLine()
  love.graphics.line(player.pos.x, player.pos.y, edgePoint.x, edgePoint.y)
end
