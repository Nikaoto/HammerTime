Player = Object:extend()

function Player:new(posX, posY, hp, sp, sprite, hammer, rigidbody, controller)
	self.posX = posX
	self.posY = posY
	self.hp = hp	--Health Points
	self.sp = sp	--Stamina Points

	--Injecting classes
	self.sprite = sprite
	self.hammer = hammer
	self.rigidbody = rigidbody
	self.controller = controller

	--Setting origin x and y
	self.oX = self.sprtie:getWidth()/2
	self.oY = self.sprite:getHeight()/2

	self.dead = false
	self.speed = MOVESPEED
end

--Gets the input from the joystick configured in controller
function Player:getInput()
	self.controller:getInput()
end

function Player:update(dt)
	self:getInput()
end

function Player:draw()
	--love.graphics.circle('fill', self.x, self.y, self.radius)
	love.graphics.print("Player "..self.name.." has "..self.hp.." HP has movespeed "..MOVESPEED)
end
