Player = Object:extend()

require "physics"
require "math1"

function Player:new(posX, posY, hp, sp, sprite, weapon,
										world, userData, shader, controller, particleSys)
	--Setting maximum and current Health and Stamina points
	self.maxHp, self.currHp = hp, hp
	self.maxSp, self.currSp = sp, sp
	--Injecting classes
	self.controller = controller
	self.weapon = weapon
	self.shader = shader
	self.particleSys = particleSys
	--General variables
	self.dead = false
	self.isSwinging = false
	self.moveSpeed = MOVESPEED
	self.regenSp = SP_REGEN
	self.sprite = sprite
	--Setting origin x and y
	self.ox = self.sprite:getWidth()/2
	self.oy = self.sprite:getHeight()/2
	--Setting look x and y
	self.lookX = 0
	self.lookY = 0
	--Setting death x and y
	self.deathX = 0
	self.deathY = 0
	--Rigidbody table
	self.rigid = {
		--Rotation speed
		rotSpeed = 0,
		--Body
		body = love.physics.newBody(world, posX, posY, "dynamic"),
		--Circle Shape
		shape = love.physics.newCircleShape(self.oy)
	}
	--Setting Rigid values
	self.rigid.body:setMass(45)
	self.rigid.body:setLinearDamping(20)
	self.rigid.body:setAngularDamping(10)
	--Fixture (attaches shape to body)
	self.rigid.fixture = love.physics.newFixture(self.rigid.body, self.rigid.shape)
	self.rigid.fixture:setUserData(userData) --Used for collisions
	--Setting position
	self.rigid.body:setPosition(posX, posY)
	--Joining weapon and player
	self.joint = love.physics.newFrictionJoint(self.rigid.body,
																				  self.weapon:getRigidBody(),
																				  self.ox,	--anchor X
																				  self.oy,	--anchor Y
																				  false)--They don't collide
	--
end

function Player:update(dt)
	if not self.dead then
		self.controller:getInput()
		self:checkControls()
		self.shader:update()
		self.particleSys:update(dt)
		self:move()
		self:updateWeapon()
		self:rotate()
		self:rotateWeapon()
		self:checkSwingSpeed(TICK)
		self:manageStamina(dt)
	end
end

--Checks for button presses and does actions accordingly
function Player:checkControls()
	--Checking if paused
	if self:getController():checkPauseBtn() and not PAUSED then
		PAUSED = true
	else
		PAUSED = false
	end

	--Checking if swinging (and has enough stamina to swing)
	if not self:getController():checkSwingBtn() then
		self.isSwinging = false
	elseif self:checkEnoughStamina(MIN_SWING_STAMINA) then
		self.isSwinging = true
	end

	--Setting movespeed according to swing status
	if self.isSwinging then
		self.moveSpeed = MOVESPEED_WHEN_SWINGING
	else
		self.moveSpeed = MOVESPEED
	end
	--Checking if dashing
	if self:getController():checkDashBtn() and self:checkEnoughStamina(DASHCOST)
	then
		 --Player:dash()
		 --TODO player dash
	end

end

function Player:checkEnoughStamina(cost)
	return self.currSp >= cost
end

--Handles player movement
function Player:move()
	--Have to do this so velocity doesn't reset
	local velX, velY = self.rigid.body:getLinearVelocity()
	if self.controller:getMoveX() ~= 0 then
		self.rigid.body:setLinearVelocity(
											self.controller:getMoveX() * self.moveSpeed,
											velY)
  end

	local velX, velY = self.rigid.body:getLinearVelocity()
	if self.controller:getMoveY() ~= 0 then
		self.rigid.body:setLinearVelocity(
											velX,
											self.controller:getMoveY() * self.moveSpeed)
	end

		self.rigid.body:setPosition(
			testScreenCollision(
				self:getX(), self:getY(), self.ox, self.oy, self.sprite:getWidth(), self.sprite:getHeight()))
end

--Handles weapon movement
function Player:updateWeapon()
	if self.isSwinging then
		self.weapon:setPosition((self:getX() + self.lookX) / 2,
													  (self:getY() + self.lookY) / 2)
		self.weapon:getRigidBody():setActive(true)
  else
		self.weapon:setPosition(self:getX(), self:getY())
		self.weapon:getRigidBody():setActive(false)
	end
end

--Handles player rotation
function Player:rotate()
	--Get rotation
	local rot = self:getController():getRotation(self:getX(),
																							 self:getY(),
																							 self.lookX,
																							 self.lookY)

	--Sets rigidbody rotation if player is rotating
	if rot then
		self.rigid.body:setAngle(rot)
	end

	--Getting changes in look direction (sets invisible crosshair location)
	local lx = self:getController():getLookX()
	local ly = self:getController():getLookY()

	--Applying if change detected
	self.lookX = self:getX() + lx * LOOK_DISTANCE
	self.lookY = self:getY() + ly * LOOK_DISTANCE
	--print("lookX: "..self:getController():getLookX().."; lookY: "..self:getController():getLookY())
end

--Handles weapon rotation
function Player:rotateWeapon()
	self.weapon:setRotation(self:getRotation())
end

function Player:checkSwingSpeed(interval)
	--Set interval counter
	local nextTick = interval
	--Set starting time
	local time = love.timer.getTime()
	--Save player rotation in radians
	local rotA = self.rigid.body:getAngle()
	--Save weapon X and Y
	local savedX = self.weapon:getX()
	local savedY = self.weapon:getY()
	--Check if time elapsed
	if(time >= nextTick) then
		--Calculate difference between saved and current positions
		self.weapon.deltaX = savedX - self.weapon:getX()
		self.weapon.deltaY = savedY - self.weapon:getY()
		--Calculate difference between saved and current rotations in time
		self.rigid.rotSpeed = (self.rigid.body:getAngle() - rotA) / interval
		--Set next rotation check time
		nextTick = time + interval;
	end
end

function Player:manageStamina(dt)
	if self:getController():checkSwingBtn() then
		--Calculating swing distance for stamina loss
		--local sw = math.distance(self.weapon.deltaX, self.weapon.deltaY)
		--Reduce stamina
		self.currSp = self.currSp - SWINGCOST * dt * 4

		--Check in case of sp underflow
		if self.currSp <= 0 then
			self.isSwinging = false
			self.currSp = 0
		end
	else
		--Regenerate stamina
		self.currSp = self.currSp + dt * self.regenSp
		--Check in case of Sp overflow
		if self.currSp >= self.maxSp  then self.currSp = self.maxSp end
	end
end

function Player:draw()
		--Setting player color (shader)
		love.graphics.setShader(self.shader:getShader())
	if not self.dead then
		--Drawing player
		love.graphics.draw(self.sprite, self:getX(), self:getY(), self:getRotation(), 1, 1, self.ox, self.oy);

		--Crosshair (for testing)
		--love.graphics.draw(LOOK_SPRITE, self.lookX, self.lookY, 0, 1, 1, 10, 10);

		--Drawing weapon if swinging
		if self.isSwinging then
			self.weapon:draw()
		end

		--Drawing particles
		love.graphics.draw(self.particleSys, self:getX(), self:getY(),
											 self.particleSys:getDirection(), 0.5, 0.5)
	else
		love.graphics.print({{255,0,0},"R.I.P."}, self.deathX, self.deathY, 0, 2, 2)

		--Drawing particles
		love.graphics.draw(self.particleSys, self.deathX, self.deathY,
											 self.particleSys:getDirection(), 0.5, 0.5)
	end
	--Removing shader
	love.graphics.setShader()
end

function Player:drawStatusBars()
	if not self.dead then
		love.graphics.reset()
		--Drawing HP and SP bars
		self:drawStatusBar(self.currHp, self.maxHp,
											 self:getX() - HPBAR_WIDTH / 2 + 1,
											 self:getY() - self.oy - HPBAR_YOFFSET,
											 HPBAR_WIDTH, HPBAR_HEIGHT, COLOR_GREY, COLOR_RED)
		self:drawStatusBar(self.currSp, self.maxHp,
											 self:getX() - SPBAR_WIDTH / 2 + 1,
											 self:getY() - self.oy - SPBAR_YOFFSET,
											 SPBAR_WIDTH, SPBAR_HEIGHT, COLOR_YELLOW, COLOR_GREEN)
		love.graphics.reset()
	end
end
--For drawing Health and Stamina bars
function Player:drawStatusBar(currFill, maxFill, x, y, width, height, backgroundColor, foregroundColor)
	love.graphics.setColor(backgroundColor)
	love.graphics.rectangle("fill", x, y, width, height, 4, 4)
	love.graphics.setColor(foregroundColor)
	if currFill > 0 then
		love.graphics.rectangle("fill", x, y, width * currFill / maxFill, height ,5,5)
	end
end

function Player:checkDeath()
	--Check HP
	self.dead =  self.currHp <= 0
	--RIP
	if self.dead then
		self.deathX, self.deathY = self.rigid.body:getX(), self.rigid.body:getY()
		self:emitDeathParticles(PARTICLE_MIN_SPEED * 10, PARTICLE_MAX_SPEED * 18, 70, math.pi)
		self.rigid.body:destroy()
	end
end

function Player:emitDeathParticles(vMin, vMax, partNum, spread)
	local prevSpread = self.particleSys:getSpread()
	self.particleSys:setSpread(spread)
	self.particleSys:setSpeed(vMin, vMax)
	self.particleSys:emit(partNum)
end

function Player:emitParticles(vMin, vMax, partNum, rotation)
	self.particleSys:setSpeed(vMin, vMax)
	self.particleSys:setDirection(rotation)
	self.particleSys:emit(partNum)
end

--Getters and Setters--
function Player:getRotation()
	return self.rigid.body:getAngle()
end

function Player:getX()
	return self.rigid.body:getX()
end

function Player:getY()
	return self.rigid.body:getY()
end

function Player:setX(x)
	return self.rigid.body:setX(x)
end

function Player:setY(y)
	return self.rigid.body:setY(y)
end

function Player:setPosition(x, y)
	self.rigid.body:setPosition(x, y)
end

function Player:getController()
	return self.controller
end

function Player:setCurrHp(hp)
	self.currHp = hp
end

function Player:getCurrHp()
	return self.currHp
end
