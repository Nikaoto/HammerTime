--Libraries
Object = require 'libraries/classic/classic'
require 'libraries/HC'

--
require 'config'
require 'math1'
require 'physics'

--Classes
require 'objects/Player'
require 'objects/Hammer'
require 'objects/Controller'
require 'objects/PlayerShader'

players = {}

function initWorld()
	love.window.setMode(display.width, display.height, display.settings)
	love.window.setTitle("Hammer Time")
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	BG = love.graphics.newImage("/res/background1.png")
	BG:setWrap("repeat","repeat")
end

function initConstants()
	--Meta Constants
	PAUSED = false
	SPAWN_SAFEZONE = 20

	--Gameplay Constatns
	MOVESPEED = 400
	MOVESPEED_WHEN_SWINGING = 190
	HP = 100
	SP = 100

	--Calculation Constants
	TICK = 0.2
	SP_REGEN = 70
	LOOK_DISTANCE = 80
	SWINGCOST = 20
	MIN_SWING_STAMINA = 10
	DASHCOST = 40 --used without dt (40% of max stamina)
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

	--Sprites
	LOOK_SPRITE = love.graphics.newImage("/res/aim.png")
	PLAYER_SPRITE = love.graphics.newImage("/res/player.png")
	HAMMER_SPRITE = love.graphics.newImage("/res/hammer.png")

	backgroundMusic = love.audio.newSource("/res/bgmusic.mp3", "stream")
	backgroundMusic:setLooping(true)
end

function love.load()
	initWorld()
	initConstants()
	backgroundMusic:play()
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
		players[i] = Player(x, y, HP, SP, PLAYER_SPRITE, weapon, world, "P"..i, playerShader, controller)
		i = i + 1
	end
end

function love.update(dt)
	checkPaused()
	if not PAUSED then
		world:update(dt)
		for i, player in ipairs(players) do
			player:update(dt)
		end
	end
end

function love.draw()
	if not PAUSED then
		drawBG(BG, 1.8, 1.8)
		for i, player in ipairs(players) do
			player:draw()
			player:drawStatusBars()
		end
	end
end

function drawBG(bg, scaleX, scaleY)
	for x = 0, display.width, bg:getWidth() * scaleX do
		for y = 0, display.height, bg:getHeight() * scaleX do
			love.graphics.draw(bg, x, y, 0, scaleX, scaleY, 0, 0)
		end
	end
end

function love.keypressed(key)
	if(key == "escape") then
		love.event.quit();
	end
end

--prints PAUSED if paused
function checkPaused()
	if PAUSED then
		love.graphics.print({{255,0,0,},"PAUSED"}, display.width/2 - 20, display.height/2, 0, 2, 2)
	end
	return PAUSED
end

--Knocks back the player and deals damage
function hitPlayer(playerFixture, coll)
	--Gets x and y of the collision force
	local nx, ny = coll:getNormal()
	--Knocks the Player back
	playerFixture:getBody()
									:applyLinearImpulse(nx * HIT_KNOCKBACK, ny * HIT_KNOCKBACK)
  print(nx * HIT_KNOCKBACK.."  "..ny * HIT_KNOCKBACK)
	--Player index
	local i = tonumber(string.sub(playerFixture:getUserData(), 2, 2))
	--Deals damage to the Player
	players[i]:setCurrHp(
		players[i]:getCurrHp() - math.vectorAbs(nx, ny) * HITMOD)
	players[i]:checkDeath()
end

--Collisions
function beginContact(a, b, coll)
	--if "a" object is a hammer
	if string.match(a:getUserData(), "H") then
		if string.match(b:getUserData(), "P") then
			print("a is hammer")
			hitPlayer(b, coll)
		elseif string.match(b:getUserData(), "H") then
			--TODO parry
		end
	--if "b" object is a hammer
	elseif string.match(b:getUserData(), "H") then
		if string.match(a:getUserData(), "P") then
			print("b is hammer")
			hitPlayer(a, coll)
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
