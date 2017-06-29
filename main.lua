--Libraries
Object = require 'libraries/classic/classic'

--
require 'conf'
require 'math1'
require 'physics'
require 'welcomescreen'
require 'bloomShader'
require 'helmetmanager'
require 'cloudmanager'

--Classes
require 'objects/Player'
require 'objects/Hammer'
require 'objects/Controller'
require 'objects/PlayerShader'

font = love.graphics.newFont("/res/junegull.ttf", 28)
bigFont = love.graphics.newFont("/res/junegull.ttf", 50)
players = {}
GAME_STARTED = false

--Window
--love.window.setMode(display.width, display.height, display.settings)
love.window.setTitle(gameTitle)

--Sounds
hitSound = love.audio.newSource("/res/hit.ogg", "static")
dodgeSounds = {}
dodgeSounds[1] = love.audio.newSource("/res/dodge1.ogg", "static")
dodgeSounds[2] = love.audio.newSource("/res/dodge2.ogg", "static")

deathSounds = {}
deathSounds[1] = love.audio.newSource("/res/death1.ogg", "static")
deathSounds[2] = love.audio.newSource("/res/death2.ogg", "static")
deathSounds[3] = love.audio.newSource("/res/death3.ogg", "static")
--Background Music
backgroundMusic = love.audio.newSource("/res/bgmusic.ogg", "stream")
backgroundMusic:setLooping(true)
skyBG = love.graphics.newImage("/res/sky.png")
skyBG2 = love.graphics.newImage("/res/sky2.png")

 local grassScaleX = 1
 local grassScaleY = 1

function love.load()
    initClouds()
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
  newPillar = love.graphics.newImage("/res/newPillar.png")
  asd = love.graphics.newImage("/res/asd.png")
  brejk = love.graphics.newImage("/res/brejk.png")

	--fullBG = love.graphics.newImage("/res/bg.png")
	--BG = love.graphics.newImage("/res/background1.png")
	--BG:setWrap("repeat","repeat")
end

function initConstants()
	--Meta Constants
	SPAWN_SAFEZONE = 180
  PLAYER_RADIUS = 30

	--Gameplay Constatns
	MOVESPEED = 400
	MOVESPEED_WHEN_SWINGING = 190
	HP = 100
	SP = 100
  MAX_KILLCOUNT = 100
  totalKills = 0
  DEATH_TIME = 4

	FALL_LIMIT_TOP = 60
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
	DASHCOST2 = 60 --used without dt (40% of max stamina)
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
  DEFAULT_BLOOD_PARTICLE_SPREAD = math.pi / 2

	--Sprites & Textures
	LOOK_SPRITE = love.graphics.newImage("/res/aim.png")
	PLAYER_SPRITE = love.graphics.newImage("/res/player.png")
	HAMMER_SPRITE = love.graphics.newImage("/res/hammer3.png")

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
	psystem:setSpread(DEFAULT_BLOOD_PARTICLE_SPREAD)
	local c = {255, 255, 255, 255}
	local fade = {255, 255, 255, 0}
	psystem:setColors(c, c, c, c, c, c, fade) -- Fade to transparency.
end

function initPlayers()
	local joys = love.joystick.getJoysticks()
	local j = love.joystick.getJoystickCount()
	local interval = display.width / j

  initHelmets()

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
     local helm
     if helmetCount < i then
       helm = helmetImage[math.random(1, 6)]
     else
       helm = helmetImages[i]
     end
    players[i] = Player(x, y, HP, SP, helm, weapon, world, "P"..i,
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

function drawEnd()
  love.graphics.setBackgroundColor(255, 0, 0, 255)
  love.graphics.setColor(0, 0,0,255)
  love.graphics.print("Thanks for playing! :) \nOne of you had more kills than all the others,\nbut because this game is made with LOVE,\nyou all win <3")
  love.graphics.setColor(255,255,255,255)

end

function love.draw()
	if GAME_STARTED then
    if MAX_KILLCOUNT == totalKills then
      drawEnd()
    else
  		--Drawing Background Items
  		--drawBG(BG, 1.8, 1.8)
  		drawSky(skyBG)
  		--drawPillar()
  		--drawPillarShadow()
      drawNewPillar(brejk, 1.30)
  		--drawGrass()
  		for i, player in ipairs(players) do
  			player:drawParticles()
  		end
  		for i, player in ipairs(players) do
  			player:draw()
  			player:drawStatusBars()
  		end
      drawTotalKills()
    end
	else drawWelcomeScreen() end
end

function drawNewPillar(img, xscale)
  love.graphics.draw(img, (display.width - img:getWidth() * xscale) /2, FALL_LIMIT_TOP-10, 0, xscale, 0.90)
end

function drawSky(img)
	love.graphics.draw(img, 0, 0, 0, display.width / skyBG:getWidth(), display.height / skyBG:getHeight())
end

function drawPillar()
	love.graphics.setShader(bloomShader)
	love.graphics.draw(dirtTile, pillarQuad, FALL_LIMIT_LEFT, display.height - dirtTile:getHeight())
	love.graphics.setShader()
end

function drawPillarShadow()
	love.graphics.setBlendMode('subtract')
	love.graphics.setColor(200, 200, 200, 20)
	love.graphics.rectangle('fill',
		FALL_LIMIT_LEFT, display.height - FALL_LIMIT_BOTTOM,
		display.width - FALL_LIMIT_RIGHT - FALL_LIMIT_LEFT, FALL_LIMIT_BOTTOM/1.5)
	love.graphics.reset()
end

--local grassDrawRot = -90
function drawGrass()
--[[	for x = FALL_LIMIT_LEFT, display.width - FALL_LIMIT_RIGHT, grassTile:getWidth() * grassScaleX do
		for y = FALL_LIMIT_TOP, display.height - FALL_LIMIT_BOTTOM - grassTile:getHeight(), grassTile:getHeight() * grassScaleY do
			love.graphics.draw(grassTile, x + grassTile:getWidth()/2, y + grassTile:getHeight()/2, rot, grassScaleX, grassScaleY, grassTile:getWidth()/2, grassTile:getHeight()/2)
		end
	end]]
	love.graphics.setShader(bloomShader)
	love.graphics.draw(grassTile, grassQuad, FALL_LIMIT_LEFT, FALL_LIMIT_TOP)
  love.graphics.setShader()
end

--[[function drawBG(bg, scaleX, scaleY)
	for x = 0, display.width, bg:getWidth() * scaleX do
		for y = 0, display.height, bg:getHeight() * scaleX do
			love.graphics.draw(bg, x, y, 0, scaleX, scaleY, 0, 0)
		end
	end
end]]

function drawTotalKills()
  love.graphics.setColor( 0,0,0,255)
  love.graphics.setFont(bigFont)
  love.graphics.print(MAX_KILLCOUNT - totalKills.." KILLS REMAINING",
        (display.width - 400)/2, 10)
  love.graphics.setColor(255, 255, 255, 255)
end

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
  love.audio.play(hitSound)
	--Gets x and y of the collision force
	local nx, ny = coll:getNormal()
  --Player index
	local i = tonumber(string.sub(playerFixture:getUserData(), 2, 2))
  local hitter = tonumber(string.sub(otherFixture:getUserData(), 2, 2))
  if not players[i].isDashing then
	--Knocks the Player back
	playerFixture:getBody()
									:applyLinearImpulse(nx * HIT_KNOCKBACK, ny * HIT_KNOCKBACK)

  --Deals damage to the Player
	players[i]:setCurrHp(
		players[i]:getCurrHp() - math.vectorAbs(nx, ny) * HITMOD)
  end

	local x1, y1, x2, y2 = coll:getPositions()

	--Updating particle positions
	players[i].partX, players[i].partY = x2, y2
	--Emitting particles
	players[i]:emitParticles(PARTICLE_MIN_SPEED, PARTICLE_MAX_SPEED,
													 45, otherFixture:getBody():getAngle())
	players[i].isStunned = true
	players[i]:checkDeath(true)
end

--Collisions
function beginContact(a, b, coll)
	--if "a" object is a hammer
	if string.match(a:getUserData(), "H") then
		if string.match(b:getUserData(), "P") then
			hitPlayer(b, coll, a)
		elseif string.match(b:getUserData(), "H") then
			--TODO parry
		end
	--if "b" object is a hammer
	elseif string.match(b:getUserData(), "H") then
		if string.match(a:getUserData(), "P") then
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
