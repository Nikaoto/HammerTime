--Libraries
Object = require 'libraries/classic/classic'

--
require 'config'
require 'math1'
require 'physics'
require 'welcomescreen'
require 'bloomShader'
--require 'cloudmanager'

--Classes
require 'objects/Player'
require 'objects/Hammer'
require 'objects/Controller'
require 'objects/PlayerShader'

players = {}
GAME_STARTED = false

--Window
love.window.setMode(display.width, display.height, display.settings)
love.window.setTitle("Hammer Time")


--Background Music
backgroundMusic = love.audio.newSource("/res/bgmusic.mp3", "stream")
backgroundMusic:setLooping(true)


 local grassScaleX = 1
 local grassScaleY = 1

function love.load()
		loadWelcomeScreen()
		backgroundMusic:play()
end

function initWorld()
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	grassTile = love.graphics.newImage("/res/grassTile.png")
	grassTile:setWrap("repeat", "repeat")
	dirtTile = love.graphics.newImage("/res/dirtTile.png")
	dirtTile:setWrap("repeat", "clampzero")
	skyBG = love.graphics.newImage("/res/sky.png")
	--fullBG = love.graphics.newImage("/res/bg.png")
	--BG = love.graphics.newImage("/res/background1.png")
	--BG:setWrap("repeat","repeat")
end

function initConstants()
	--Meta Constants
	--PAUSED = false
	SPAWN_SAFEZONE = 20

	--Gameplay Constatns
	MOVESPEED = 400
	MOVESPEED_WHEN_SWINGING = 190
	HP = 100
	SP = 100
	FALL_LIMIT_TOP = 40
	FALL_LIMIT_BOTTOM = 60
	FALL_LIMIT_LEFT = 50
	FALL_LIMIT_RIGHT = 50

	--Calculation Constants
	TICK = 0.2
	SP_REGEN = 70
	LOOK_DISTANCE = 80
	DASH_DISTANCE = 150
  DASH_SPEED = 5000
	SWINGCOST = 20
	MIN_SWING_STAMINA = 10
	DASHCOST = 50 --used without dt (40% of max stamina)
	HITMOD = 10 --used for hit damage modification
	HIT_KNOCKBACK = 10000 --used for knockback modification

	--Offests / Drawing Constants
	HPBAR_HEIGHT = 8
	HPBAR_YOFFSET = 13
	HPBAR_WIDTH = 55
	SPBAR_HEIGHT = 4
	SPBAR_YOFFSET = 6
	SPBAR_WIDTH = 55
	COLOR_GREEN = {0, 255, 0}
	COLOR_RED = {255, 0, 0}
	COLOR_YELLOW = {255, 255, 0}
	COLOR_GREY = {140, 140, 140, 160}

	--Sprites & Textures
	LOOK_SPRITE = love.graphics.newImage("/res/aim.png")
	PLAYER_SPRITE = love.graphics.newImage("/res/player.png")
	HAMMER_SPRITE = love.graphics.newImage("/res/hammer.png")

	--Pillar drawing space
	pillarQuad = love.graphics.newQuad(0, 0,
		display.width - FALL_LIMIT_LEFT - FALL_LIMIT_RIGHT,
		dirtTile:getHeight(), dirtTile:getWidth(), dirtTile:getHeight())

	--Grass / Ground drawing space
	grassQuad = love.graphics.newQuad(0, 0,
	 display.width - FALL_LIMIT_LEFT - FALL_LIMIT_RIGHT,
	 display.height - FALL_LIMIT_TOP - FALL_LIMIT_BOTTOM,
	 grassTile:getWidth(), grassTile:getHeight())

	--Particles
	PARTICLE_MIN_SPEED = 300
	PARTICLE_MAX_SPEED = 1500
	bloodParticle = love.graphics.newImage("/res/bloodParticle.png")
	psystem = love.graphics.newParticleSystem(bloodParticle, 64)
	psystem:setParticleLifetime(0.1, 0.5)
	psystem:setSizeVariation(0.5)
	psystem:setSpread(math.pi / 2)
	local c = {255, 255, 255, 255}
	local fade = {255, 255, 255, 0}
	psystem:setColors(c, c, c, c, c, c, fade) -- Fade to transparency.
end

function initPlayers()
	local joys = love.joystick.getJoysticks()
	local j = love.joystick.getJoystickCount()
	local interval = display.width / j

	for i, joystick in ipairs(joys) do
		math.randomseed(i)
		local upper = i * interval - SPAWN_SAFEZONE
		local lower = (i - 1) * interval + SPAWN_SAFEZONE
		math.randomseed(i * os.time())
		local x = math.random(lower, upper)
		local y = math.random(SPAWN_SAFEZONE, display.height - SPAWN_SAFEZONE)
		--Creating player
		local controller = Controller(joystick)
		local weapon = Hammer(x, y, HAMMER_SPRITE, world, "H"..i)
		local playerShader = PlayerShader(math.random(0, 255),	--Red
																			math.random(0, 255),	--Green
																			math.random(0, 255))	--Blue
		players[i] = Player(x, y, HP, SP, PLAYER_SPRITE, weapon, world, "P"..i,
												playerShader, controller, psystem:clone())
		i = i + 1
	end
end

function loadGame()
	initWorld()
	initConstants()
	initPlayers()
	GAME_STARTED = true
end

function love.update(dt)
	updateBloomShader()
	if GAME_STARTED then
		world:update(dt)
		for i, player in ipairs(players) do
			player:update(dt)
		end
	else updateWelcomeScreen(dt) end
end

function love.draw()
	if GAME_STARTED then
		--Drawing Background Items
		--drawBG(BG, 1.8, 1.8)
		drawSky()
		drawPillar()
		drawPillarShadow()
		drawGrass()
		for i, player in ipairs(players) do
			player:drawParticles()
		end
		for i, player in ipairs(players) do
			player:draw()
			player:drawStatusBars()
		end
	else drawWelcomeScreen() end
end

function drawSky()
	love.graphics.draw(skyBG, 0, 0, 0, display.width / skyBG:getWidth(), display.height / skyBG:getHeight())
end

function drawPillar()
	love.graphics.setShader(bloomShader)
	love.graphics.draw(dirtTile, pillarQuad, FALL_LIMIT_LEFT, display.height - dirtTile:getHeight())
	love.graphics.setShader()
end

function drawPillarShadow()
	love.graphics.setBlendMode('subtract')
	love.graphics.setColor(200, 200, 200, 50)
	love.graphics.rectangle('fill',
		FALL_LIMIT_LEFT, display.height - FALL_LIMIT_BOTTOM,
		display.width - FALL_LIMIT_RIGHT - FALL_LIMIT_LEFT, FALL_LIMIT_BOTTOM/1.5)
	love.graphics.reset()
end

--local grassDrawRot = -90
function drawGrass()
	--[[local rot = 0
	for x = FALL_LIMIT_LEFT, display.width - FALL_LIMIT_RIGHT, grassTile:getWidth() * grassScaleX do
		for y = FALL_LIMIT_TOP, display.height - FALL_LIMIT_BOTTOM - grassTile:getHeight(), grassTile:getHeight() * grassScaleY do
			love.graphics.draw(grassTile, x + grassTile:getWidth()/2, y + grassTile:getHeight()/2, rot, grassScaleX, grassScaleY, grassTile:getWidth()/2, grassTile:getHeight()/2)
		end
	end]]
	love.graphics.setShader(bloomShader)
	love.graphics.draw(grassTile, grassQuad, FALL_LIMIT_LEFT, FALL_LIMIT_TOP)
end

--[[function drawBG(bg, scaleX, scaleY)
	for x = 0, display.width, bg:getWidth() * scaleX do
		for y = 0, display.height, bg:getHeight() * scaleX do
			love.graphics.draw(bg, x, y, 0, scaleX, scaleY, 0, 0)
		end
	end
end]]

function love.keypressed(key)
	if key == "escape" then
		love.event.quit();
	end
end

function love.joystickpressed()
	if not GAME_STARTED then
		loadGame()
	end
end

--[[--prints PAUSED if paused
function checkPaused()
	if PAUSED then
		love.graphics.print({{255,0,0,},"PAUSED"}, display.width/2 - 20, display.height/2, 0, 2, 2)
	end
end]]

--Knocks back the player, deals damage, and shoots particles
function hitPlayer(playerFixture, coll, otherFixture)
	--Gets x and y of the collision force
	local nx, ny = coll:getNormal()
  --Player index
	local i = tonumber(string.sub(playerFixture:getUserData(), 2, 2))

  if not players[i].isDashing then
	--Knocks the Player back
	playerFixture:getBody()
									:applyLinearImpulse(nx * HIT_KNOCKBACK, ny * HIT_KNOCKBACK)
  end

	local x1, y1, x2, y2 = coll:getPositions()

	--Updating particle positions
	players[i].partX, players[i].partY = x2, y2
	--Emitting particles
	players[i]:emitParticles(PARTICLE_MIN_SPEED, PARTICLE_MAX_SPEED,
													 45, otherFixture:getBody():getAngle())
	--Deals damage to the Player
	players[i]:setCurrHp(
		players[i]:getCurrHp() - math.vectorAbs(nx, ny) * HITMOD)
	players[i].isStunned = true
	players[i]:checkDeath()
end

--Collisions
function beginContact(a, b, coll)
	--if "a" object is a hammer
	if string.match(a:getUserData(), "H") then
		if string.match(b:getUserData(), "P") then
			print("a is hammer")
			hitPlayer(b, coll, a)
		elseif string.match(b:getUserData(), "H") then
			--TODO parry
		end
	--if "b" object is a hammer
	elseif string.match(b:getUserData(), "H") then
		if string.match(a:getUserData(), "P") then
			print("b is hammer")
			hitPlayer(a, coll, a)
		elseif string.match(a:getUserData(), "H") then
			--parry
		end
	end
end

function endContact(a,b,coll)
end

function preSolve(a,b,coll)
end

function postSolve(a,b,coll)
end
