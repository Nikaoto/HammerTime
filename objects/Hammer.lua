Hammer = Object:extend()

function Hammer:new(posX, posY, sprite, world, userData)
  --Setting sprite
  self.sprite = sprite
  --Setting origin X and Y offsets
  self.ox = sprite:getWidth()/2
  self.oy = sprite:getHeight()/2
  --Rigidbody table
  self.rigid = {
    --Body
    body = love.physics.newBody(world, posX, posY, "dynamic"),
    --Rectangle Shape
    shape = love.physics.newRectangleShape(self.sprite:getWidth()*0.8,
                                          self.sprite:getHeight()*0.9)
    --fixture
  }
  self.rigid.body:setMass(0)
  self.rigid.body:setLinearDamping(20)
  --Fixture (attaches shape to body)
  self.rigid.fixture = love.physics.newFixture(self.rigid.body, self.rigid.shape)
  self.rigid.fixture:setUserData(userData) --For detecting collisions
  --self.rigid.fixture:setSensor(true)
  --Setting position
  self.rigid.body:setPosition(posX, posY)
end

function Hammer:getRigidBody()
  return self.rigid.body
end

function Hammer:draw()
  love.graphics.draw(self.sprite, self:getX(), self:getY(), self.rigid.body:getAngle(), 0.5, 0.5, self.ox, self.oy)
end

function Hammer:setRotation(radians)
  self.rigid.body:setAngle(radians)
end

function Hammer:setPosition(x, y)
  self.rigid.body:setPosition(x, y)
end

function Hammer:getX()
  return self.rigid.body:getX()
end

function Hammer:getY()
  return self.rigid.body:getY()
end
