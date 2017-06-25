Player = Object:extend()

require "physics"
require "math1"

function Player:new(posX, posY, hp, sp, sprite, weapon,
										world, userData, shader, controller, particleSys)
	--Setting maximum Health and Stamina points
	self.maxHp, self.maxSp =  hp, hp
	--Injecting classes
	self.controller = controller
	self.weapon = weapon
	self.shader = shader
	self.particleSys = particleSys

	--Origin X and Y with sprite
	self.sprite = sprite
	self.ox = self.sprite:getWidth()/2
	self.oy = self.sprite:getHeight()/2

	--Setting death x and y
	self.deathX = 0
	self.deathY = 0

	--Setting particle x and y
	self.partX = 0
	self.partY = 0

	self.killCount = 0
	self.deathCount = 0

	self:init()

	--Rigidbody table
	self.rigid = {
		--Rotation speed
		rotSpeed = 0,
		--Body
		body = love.physics.newBody(world, posX, posY, "dynamic"),
		--Circle Shape
		shape = love.physics.newCircleShape(PLAYER_RADIUS)
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

function Player:init()
	--Setting maximum and current Health and Stamina points
	self.currHp, self.currSp = self.maxHp, self.maxSp

	--General variables
	self.moveSpeed = MOVESPEED
	self.regenSp = SP_REGEN
	self.dead = false
	self.isSwinging = false
	self.isStunned = false
	self.isDashing = false

	--Setting look x and y
	self.lookX = 0
	self.lookY = 0

	self.deathTimer = -1

	self.particleSys:setSpeed(DEFAULT_BLOOD_PARTICLE_SPREAD)
end

function Player:die(sentFromOutside)
	self.dead = true
	self.deathTimer = love.timer.getTime() + DEATH_TIME
	self.deathX, self.deathY = self:getX(), self:getY()
	self.rigid.body:setLinearVelocity(0,0)
	if not sentFromOutside then
		self.rigid.body:setActive(false)
	end
end

function Player:respawn()
	math.randomseed(os.time())
	self.rigid.body:setActive(true)
	self.rigid.body:setLinearVelocity(0, 0)
	self.rigid.body:setPosition(
		math.random(SPAWN_SAFEZONE, display.width - SPAWN_SAFEZONE),
		math.random(SPAWN_SAFEZONE, display.height - SPAWN_SAFEZONE))
	self:init()
	--Play spawn animation (or display text)
end

function Player:playSpawnAnimation()
	--Maybe?
end

function Player:checkStunStatus(limit)
	if self.rigid.body:getLinearVelocity() <= limit then
		self.isStunned = false
	end
end

function Player:manageDashing()
	if self.isDashing and self.dashTime < love.timer.getTime() then
		self.isDashing = false
		self.dashTime = 0
		self.rigid.body:setActive(true)
	end
end

function Player:update(dt)
	self:checkDeath()
	if not self.dead then
		self.controller:getInput()
		self:checkControls()
		self.shader:update()
		if not self.isStunned then
			self:move()
			if not self.isDashing then
				self:updateWeapon()
				self:rotate()
				self:rotateWeapon()
				--self:checkSwingSpeed(TICK)
			end
		else
			self:checkStunStatus(10)
			self.isSwinging = false
		end

		if self:fellDown() then
			self:die()
		end
	end
		self.particleSys:update(dt)
		self:manageStamina(dt)
		self:manageDashing()
end

--Checks for button presses and does actions accordingly
function Player:checkControls()
	--Checking if swinging (and has enough stamina to swing)
	if not self:getController():checkSwingBtn() then
		self.isSwinging = false
	elseif self:checkEnoughStamina(MIN_SWING_STAMINA) then
		self.isSwinging = true
	end

	--Setting movespeed according to swing status
	if self.isSwinging then
		self.moveSpeed = MOVESPEED_WHEN_SWINGING
	elseif self.isDashing then
		self.moveSpeed = DASH_SPEED
	else
		self.moveSpeed = MOVESPEED
	end
	--Checking if dashing
	if self:getController():checkDashBtn() and self:checkEnoughStamina(DASHCOST)
		then
		self:dash(0.1)
	end
end

function Player:checkEnoughStamina(cost)
	return self.currSp >= cost
end

function Player:dash(time)
	self.isDashing = true
	self.dashTime = time + love.timer.getTime()
	self.currSp = self.currSp - DASHCOST
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

	self.rigid.body:setPosition(self:getX(), self:getY())
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
end

--Handles weapon rotation
function Player:rotateWeapon()
	self.weapon:setRotation(self:getRotation())
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
	elseif not self.isDashing then
		--Regenerate stamina
		self.currSp = self.currSp + dt * self.regenSp
		--Check in case of Sp overflow
		if self.currSp >= self.maxSp  then self.currSp = self.maxSp end
	end
end

function Player:draw()
	if self.isDashing then
		love.graphics.setShader(self.shader:getShader()) --TODO Blur shader here
	else
	--Setting player color (shader)
	love.graphics.setShader(self.shader:getShader())
	end
	if not self.dead then
		--Drawing player
		love.graphics.draw(self.sprite, self:getX(), self:getY(), self:getRotation(), 1, 1, self.ox, self.oy);
		--Crosshair (for testing)
		--love.graphics.draw(LOOK_SPRITE, self.lookX, self.lookY, 0, 1, 1, 10, 10);

		--Drawing weapon if swinging
		if self.isSwinging then
			self.weapon:draw()
		end
	else
		love.graphics.print("Respawning in "..round(self.deathTimer - love.timer.getTime()).." seconds",
			self.deathX, self.deathY, 0, 1, 1)
	end
	--Removing shader
	love.graphics.setShader()
end

function Player:drawParticles(x, y)
	--Checking if dead
	if self.dead then
		self.partX, self.partY = self.deathX, self.deathY
	end
	--Drawing particles
	love.graphics.draw(self.particleSys, self.partX or self:getX(), self.partY or self:getY(),
										 self.particleSys:getDirection(), 0.5, 0.5)
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

function Player:checkDeath(sentfromoutside)
	if self.deathTimer <= love.timer.getTime() and self.deathTimer ~= -1 then
		self:respawn()
	end
	--Check HP
	if self.currHp <= 0 and not self.dead then
		self.dead = true
		self.deathX, self.deathY = self.rigid.body:getX(), self.rigid.body:getY()
		self:emitDeathParticles(PARTICLE_MIN_SPEED * 10, PARTICLE_MAX_SPEED * 15, 90, math.pi * 2)
		self:die(sentfromoutside)
	end
end

function Player:emitDeathParticles(vMin, vMax, partNum, spread)
	self.particleSys:setSpread(spread)
	self.particleSys:setSpeed(vMin, vMax)
	self.particleSys:setDirection(math.random(0, math.pi * 2))
	self.particleSys:emit(partNum)
	self.particleSys:update(0.3)
end

function Player:emitParticles(vMin, vMax, partNum, rotation)
	self.particleSys:setSpeed(vMin, vMax)
	self.particleSys:setDirection(rotation)
	self.particleSys:emit(partNum)
end

function Player:fellDown()
		if self:getX() < FALL_LIMIT_LEFT or self:getX() > display.width - FALL_LIMIT_RIGHT then
			return true
		end

		if self:getY() < FALL_LIMIT_TOP or self:getY() > display.height - FALL_LIMIT_BOTTOM then
			return true
		end
		return false
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
