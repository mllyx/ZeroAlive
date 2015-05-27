World = class("World")

--local frameIndex = 0

local _objects = {}
function World:init(width, height)
  self.size = {}
  self.size.width = width
  self.size.height = height
  self.focus = {x = self.size.width/2, y = self.size.height/2}
end

function World:add(object)
  _objects[#_objects+1] = object
end

local function removeUnusedObjects()
  local indexes = {}
  for i, object in ipairs(_objects) do
    if object.removed == true then 
      indexes[#indexes+1] = i 
      --print('['..frameIndex..']('..i..')'..object.name..':'..object.pos.x..','..object.pos.y)
    end
  end
  for i = #indexes, 1, -1 do
    local object = table.remove(_objects, indexes[i])
    --[[
    if object == nil then
      print('['..frameIndex..']'..'out of range')
    end
    ]]--
  end
end

function World:removeOutOfRangeObjects()
  for i,object in ipairs(_objects) do  
    if object.pos.x < 0 or
       object.pos.y < 0 or
       object.pos.x > self.size.width or
       object.pos.y > self.size.height then
        object.removed = true
    end
  end
end

function World:checkCircularCollision(ax, ay, bx, by, ar, br)
  if ar == nil then ar = 0 end
  if br == nil then br = 0 end
	local dx = bx - ax
	local dy = by - ay
	return dx^2 + dy^2 < (ar + br)^2
end

function World:checkRectPointCollision(rectX, rectY, rectWidth, rectHeight, pointX, pointY)
  return pointX >= rectX and pointX <= rectX+rectWidth and pointY >= rectY and pointY <= rectY+rectHeight
end

function World:checkCircleRectCollision(circleX, circleY, circleRadius, rectX, rectY, rectWidth, rectHeight)
  if not circleRadius then circleRadius = 0 end
  
  local result = self:checkRectPointCollision(rectX-circleRadius, rectY, rectWidth+circleRadius*2, rectHeight, circleX, circleY)
  if result then return result end
  result = self:checkRectPointCollision(rectX, rectY-circleRadius, rectWidth, rectHeight+circleRadius*2, circleX, circleY)
  if result then return result end
  
  --左上
  if self:checkRectPointCollision(rectX-circleRadius, rectY-circleRadius, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX, rectY, circleRadius)
  end
  
  --右上
  if self:checkRectPointCollision(rectX+rectWidth, rectY-circleRadius, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX+rectWidth, rectY, circleRadius)
  end
  
  --左下
  if self:checkRectPointCollision(rectX-circleRadius, rectY, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX, rectY+rectHeight, circleRadius)
  end
  
  --右下
  if self:checkRectPointCollision(rectX+rectWidth, rectY+rectHeight, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX+rectWidth, rectY+rectHeight, circleRadius)
  end
  
  return false
end

function World:collide(object1, object2)
  if (class.isInstance(object1, Bullet) and class.isInstance(object2, Enemy)) or
  (class.isInstance(object1, Enemy) and class.isInstance(object2, Bullet)) then
    object1.removed = true
    object2.removed = true
  end
end

function World:update(dt)
  --frameIndex = frameIndex + 1
  for i, object in ipairs(_objects) do
    if type(object.handleInput) == 'function' then
      object:handleInput(dt)
    end
  end
  
  for i, object in ipairs(_objects) do
    if type(object.update) == 'function' then
      object:update(dt)
    end
  end
  
  for i = 1, #_objects do
    local object1 = _objects[i]
    if not object1.removed and object1.collidable then
      for j = i+1, #_objects do
        local object2 = _objects[j]
        if not object2.removed and object2.collidable then
          if self:checkCircularCollision(object1.pos.x, object1.pos.y, object2.pos.x, object2.pos.y, object1.size, object2.size) then
            self:collide(object1, object2)
          end
        end
      end
    end
  end
  
  self:removeOutOfRangeObjects()
  removeUnusedObjects()
end

function World:draw()
  love.graphics.push()
  love.graphics.translate(-self.focus.x+love.window.getWidth()/2, -self.focus.y+love.window.getHeight()/2)
  love.graphics.rectangle('line', 0, 0, self.size.width, self.size.height)
  
  local window = {}
  window.x, window.y = self:worldCoordinates(0, 0)
  window.width, window.height = love.window.getWidth(), love.window.getHeight()
  --love.graphics.line(0, window.y+window.height, self.size.width, window.y+window.height)
  for i, object in ipairs(_objects) do
    if self:checkCircleRectCollision(object.pos.x, object.pos.y, object.size, window.x, window.y, window.width, window.height) then
      object:draw()
    end
  end
  love.graphics.pop()
end

--将屏幕坐标转换为游戏坐标
function World:worldCoordinates(screenX, screenY)
  if screenX == nil or screenY == nil then return end
  return self.focus.x-love.window.getWidth()/2+screenX, self.focus.y-love.window.getHeight()/2+screenY
end

function World:mousePos()
  return self:worldCoordinates(love.mouse.getPosition())
end

function World:remove(target)
  local index = -1
  for i, object in ipairs(_objects) do
    if target == object then index = i; break end
  end
  table.remove(_objects, index)
end