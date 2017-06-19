Player = Object:extend()

function Player:new(hp, sp, name)
	self.hp = hp
	self.sp = sp
	self.name = name
	self.x = 100
	self.y = 100
	self.radius = 20
end

function Player:update(dt)

end

function Player:draw()
	--love.graphics.circle('fill', self.x, self.y, self.radius)
	love.graphics.print("Player "..self.name.." has "..self.hp.." HP")
end