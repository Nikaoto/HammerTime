Hammer = Object:extend()

local s = {}

function Hammer:new(posX, posY, sprite, world, userData)
  --Metatable for shorter slef-reference
  s = setmetatable(s, self)
  self.__index = self

  --Setting sprite
  s.sprite = sprite
  --Setting origin X and Y offsets
  s.ox = sprite:getWidth()/2
  s.ox = sprite:getHeight()/2
  --Rigidbody table
  s.rigid = {
    --Body
    body = love.physics.newBody(world, posX, posY, "dynamic"),
    --Rectangle Shape
    shape = love.physics.newRectangleShape(s.sprite:getWidth(),
                                          s.sprite:getHeight()),
    --Fixture (attaches shape to body)
    fixture = love.physics.newFixture(s.rigid.body, s.rigid.shape)
  }
  s.rigid.body:setMass(0)
  s.rigid.body:setLinearDamping(20)
  s.rigid.fixture:setUserData(userData) --For detecting collisions
  --Setting position
  s.rigid.body:setPosition(posX, posY)
end

function Hammer:update(dt)

end

function Hammer:draw()
  local x, y = s.rigid.body:getPosition()
  love.graphics.draw(s.sprite, x, y, s.rigid.body:getAngle(), 1, 1, s.ox, s.oy)
end

function Hammer:setRotation(radians)
  s.rigid.body:setAngle(radians)
end

function Hammer:setPosition(x, y)
  s.rigid.body:setPosition(x, y)
end

function Hammer:getX()
  return s.rigid.body:getX()
end

function Hammer:getY()
  return s.rigid.body:getY()
end
