Player = Object:extend()
require "physics"
require "math1"

--self
local s = {}

--Invisible crosshair location
local lookX, lookY = 0, 0

function Player:new(posX, posY, hp, sp, sprite, weapon, controller, world, userData, shader)
	--Creating s metatable so I can type "s" instead of "self"
	s = setmetatable(s, self)
	self.__index = self

	--Setting maximum and current Health and Stamina points
	s.maxHp, s.currHp = hp, hp
	s.maxSp, s.currSp = sp, sp
	--Injecting classes
	s.controller = controller
	s.weapon = weapon
	s.shader = shader
	--General variables
	s.dead = false
	s.isSwinging = false
	s.moveSpeed = MOVESPEED
	s.regenSp = SP_REGEN
	s.sprite = sprite
	--Setting origin x and y
	s.ox = s.sprtie:getWidth()/2
	s.oy = s.sprite:getHeight()/2
	--Rigidbody table
	s.rigid = {
		--Rotation speed
		rotSpeed = 0,
		--Body
		body = love.physics.newBody(world, posX, posY, "dynamic"),
		--Circle Shape
		shape = love.physics.newCircleShape(s.sprite.getWidth()/2,
																				s.sprite.getHeight()/2),
		--Fixture (attaches shape to body)
		fixture = love.physics.newFixture(s.rigid.body, s.rigid.shape)
	}
	--Setting Rigid values
	s.rigid.body:setMass(45)
	s.rigid.body:setLinearDamping(20)
	s.rigid.body:setAngularDamping(10)
	s.rigid.fixture:setUserData(userData) --Used for collisions
	--Setting position
	s.rigid.body:setPosition(posX, posY)
	--Joining weapon and player
	s.joint = love.physics.newFrictionJoint(s.rigid.body,
																				  s.weapon.rigid.body,
																				  s.ox,	--anchor X
																				  s.oy,	--anchor Y
																				  false)--They don't collide
end

function Player:update(dt)
	s.controller:getInput()
	s.shader:update()
	s:move()
	s:moveWeapon()
	s:rotate()
	s:rotateWeapon()
	s.checkSwingSpeed(TICK)
	s:manageStamina(dt)
end

--Handles player movement
function Player:move()
	s.rigid.body:setLinearVelocity(s.controller:getMoveX(), s.controller:getMoveY())
	s.rigid.body:setPosition(
		testScreenCollision(
			s:getX(), s:getY(), s.ox, s.oy, s.sprite:getWidth(), s.sprite:getHeight()
		)
	)
end

--Handles weapon movement
function Player:moveWeapon()
	if s.isSwinging then
		s.weapon:setPosition((s:getX() + lookX) / 2,
												 (s:getY() + lookY) / 2)
  else
		s.weapon:setPosition(s:getX(), s:getY())
	end
end

--Handles player rotation
function Player:rotate()
	--Getting changes in look direction (sets invisible crosshair location)
	lookX = s:getX() + s.controller:getLookX()
	lookY = s:getY() + s.controller:getLookY()
	--Sets rigidbody rotation if player is rotating
	s.rigid.body:setAngle(
		s.controller:getRotation(
			s:getX(),
			s:getY(),
			s.lookX,
			s.lookY,
			s.rigid.body:getAngle()
		)
	)
end

--Handles weapon rotation
function Player:rotateWeapon()
	s.weapon:setRotation(s:getRotation())
end

function Player:checkSwingSpeed(interval)
	--Set interval counter
	local nextTick = interval
	--Set starting time
	local time = love.timer.getTime()
	--Save player rotation in radians
	local rotA = s.rigid.body:getAngle()
	--Save weapon X and Y
	local savedX = s.weapon:getX()
	local savedY = s.weapon:getY()
	--Check if time elapsed
	if(s.time >= tend) then
		--Calculate difference between saved and current positions
		s.weapon.deltaX = savedX - s.weapon:getX()
		s.weapon.deltaX = savedY - s.weapon:getY()
		--Calculate difference between saved and current rotations
		s.rigid.rotSpeed = s.rigid.body:getAngle() - rotA;
		--Set next rotation check time
		nextTick = s.time + interval;
	end
end

function Player:manageStamina(dt)
	if(s.weapon.isSwinging) then
		--Calculating swing distance for stamina loss
		local sw = math.distance(s.weapon.deltaX, s.weapon.deltaY)
		s.currSp = s.currSp - sw / SWING_COST_MOD
		if s.currSp <=0 then
			s.isSwinging = false
		end
	else
		s.currSp = player1.currSp + dt * s.regenSp
		--Check in case of Sp overflow
		if s.currSp >= s.maxSp  then
			s.currSp = s.maxSp
		end
	end
end

function Player:draw()
	--Setting player color (shader)
	love.graphics.setShader(s.shader)
	--Drawing player
	love.graphics.draw(s.sprite, s.getX(), s.getY(), s.rigid.body:getAngle(), 1, 1, s.ox, s.oy);
	--Drawing weapon if swinging
	if s.isSwinging then
		s.weapon:draw()
	end
	--Removing shader
	love.graphics.setShader()
end

function Player:getRotation()
	return s.rigid.body:getAngle()
end

function Player:getX()
	return s.rigid.body:getX()
end

function Player:getY()
	return s.rigid.body:getY()
end

function Player:setX(x)
	return s.rigid.body:setX(x)
end

function Player:setY(y)
	return s.rigid.body:setY(y)
end

function Player:setPosition(x, y)
	s.setX(x)
	s.setY(y)
end
