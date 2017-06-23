
require "config" --Defines configuration / settings
require "joymanager"  --Manges joysticks
require "math1"  --Mthematics functions
require("physics"); --Physics methods
require("player1");
require("player2");
require("player3");

Object = require 'libraries/classic/classic'
require 'objects/Player'
require 'objects/Hammer'
require 'objects/PlayerShader'

local braxSound = love.audio.newSource("brax.ogg", "static")

function Init()
	success = love.window.setMode(display.width, display.height, display.settings)
	love.window.setTitle("Hammer Time");
	world = love.physics.newWorld(0, 0, true);
	world:setCallbacks(beginContact, endContact, preSolve, postSolve);
	BG = love.graphics.newImage("/res/background1.png");
	BG:setWrap("repeat","repeat");

	initJoysticks()

	HPBAR_YOFFSET = 10;
	SPBAR_YOFFSET = 5;
	HPBAR_HEIGHT = 8;
	SPBAR_HEIGHT = 3;
	PAUSED = false;
	PAUSEDBY = "";
	JOYDISCONNECTED = false;
	LOOK_ZONE = 80;
	SWING_MOVESPEED = 190;
	MOVESPEED = 400;
	TICK = 0.2;
	HIT = 1;
	HITMOD = 50;
	SWING_COST_MOD = 55;
	SP_REGEN = 35;
	SWINGCOST = 25;
	compatibleJoyCount = 0;
end

function love.load()
	Init();
	CheckJoyCompatibility();
	--create players
--[[	p1Hammer = Hammer(300, 400, love.graphics.newImage("/res/hammer.png"), "p1Hammer")
	function Hammer:new(posX, posY, sprite, world, userData)
	player1 = Player(300,	--posX
									 400,	--posY
									 100, --HP
									 100, --SP
									 love.graphics.newImage("/res/bloq1.png"), --Sprite
									 p1Hammer, --Weapon
									 Controller(joysticks[2]), --Controller
									 world,	--world
								 	 "P1") --User Data (for collisions)]]
	if(compatibleJoyCount > 0) then createP1();
	else print("NO JOYSTICKS RECOGNIZED, PLUG IN CONTROLLERS AND RESTART THE GAME"); end

	if(compatibleJoyCount > 1) then createP2();
	end

	if(compatibleJoyCount > 2) then createP3();
	end

	--aim = love.graphics.newImage("/res/aim.png");
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

function love.update(dt)
	if not PAUSED and not JOYDISCONNECTED then
		world:update(dt);
		if(compatibleJoyCount > 0) then
			if not(player1.dead) then
				P1Input();
				P1Control();
				P1Stamina(dt);
			end
		end
		if(compatibleJoyCount > 1) then
			if not(player2.dead) then
				P2Input();
				P2Control();
				P2Stamina(dt);
			end
		end
		if(compatibleJoyCount > 2) then
			if not(player3.dead) then
				P3Input();
				P3Control();
				P3Stamina(dt);
			end
		end
	end
end

function checkDeath(chp,body)
	if(chp <=0 ) then
		body:destroy();
		return true;
	else
		return false;
	end
end

function dealDamage(px,py,chp)
	chp = chp - round(math.sqrt(px*px + py*py)/500,0);
	return chp;
end

function drawHealthBar(hp,chp,x,y,w,h)
	y = y-HPBAR_YOFFSET;
	love.graphics.setColor(255,0,0);
	love.graphics.rectangle("fill",x, y,w,h);
	love.graphics.setColor(0,255,0);
	love.graphics.rectangle("fill",x, y,w*chp/hp,h);
	love.graphics.reset();
	--love.graphics.print({{0,255,0}, hp.."/"..chp},x,y);
end

function drawStaminaBar(sp,csp,x,y,w,h)
	y = y-SPBAR_YOFFSET;
	--love.graphics.setColor(255,255,255);
	--love.graphics.rectangle("fill",x, y,w,h);
	love.graphics.getColor(255,0,0);
	love.graphics.rectangle("fill",x, y,w*csp/sp,h);
	love.graphics.reset();
	--love.graphics.print({{0,255,0}, hp.."/"..chp},x,y);
end

function drawBG(BG,scaley,scalex)
	i = 0
	for x=0,love.graphics.getWidth(),BG:getWidth()*scalex do
		for y=0, love.graphics.getHeight(),BG:getHeight()*scaley do
			love.graphics.draw(BG,x,y,0,scalex,scaley,0,0);
		end
	end
end

function love.draw()
	if not (JOYDISCONNECTED) and not (PAUSED) then
		drawBG(BG,2,2);
		if(compatibleJoyCount == 0) then
			love.graphics.print({{255,0,0},"Please connect a controller to play"},love.graphics.getHeight()/2 - love.graphics.getHeight()/3 ,love.graphics.getWidth()/2 - love.graphics.getHeight()/3,0,2,2);
		end

		if(compatibleJoyCount > 0) then
			if not(player1.dead) then
				drawP1();
			end
		end

		if(compatibleJoyCount > 1) then
			if not(player2.dead) then
				drawP2();
			end
		end

		if(compatibleJoyCount > 2) then
			if not(player3.dead) then
				drawP3();
			end
		end

		--[[
		if(compatibleJoyCount > 3) then
			if not(player4.dead) then
				drawP4();
			end
		end
		]]--

		--DRAWING HUD STUFF
		if(compatibleJoyCount > 0) then
			if(player1.dead) then
				love.graphics.print({{255,0,0}, "R.I.P."},player1.x,player1.y,0,2,2);
			else
				--draw p1 health
				drawHealthBar(player1.hp,player1.chp,player1.x - player1.ox, player1.y - player1.oy,player1.sprite:getWidth(),HPBAR_HEIGHT);

				--draw p1 stamina
				drawStaminaBar(player1.sp,player1.csp,player1.x - player1.ox, player1.y - player1.oy,player1.sprite:getWidth(),SPBAR_HEIGHT);
			end
		end

		if(compatibleJoyCount > 1) then
			if(player2.dead) then
				love.graphics.print({{0,0,255}, "R.I.P."},player2.x,player2.y,0,2,2);
			else
				--draw p2 health
				drawHealthBar(player2.hp,player2.chp,player2.x - player2.ox, player2.y - player2.oy,player2.sprite:getWidth(),HPBAR_HEIGHT);

				--draw p2 stamina
				drawStaminaBar(player2.sp,player2.csp,player2.x - player2.ox, player2.y - player2.oy,player2.sprite:getWidth(),SPBAR_HEIGHT);
			end
		end

		if(compatibleJoyCount > 2) then
			if(player3.dead) then
				love.graphics.print({{0,255,0}, "R.I.P."},player3.x,player3.y,0,2,2);
			else
				--draw p3 health
				drawHealthBar(player3.hp,player3.chp,player3.x - player3.ox, player3.y - player3.oy,player3.sprite:getWidth(),HPBAR_HEIGHT);

				--draw p3 stamina
				drawStaminaBar(player3.sp,player3.csp,player3.x - player3.ox, player3.y - player3.oy,player3.sprite:getWidth(),SPBAR_HEIGHT);
			end
		end
		--END OF DRAWING HUD STUFF
	else
		if(JOYDISCONNECTED) then
			love.graphics.print({{255,0,0},"Please reconnect the controller!"},love.graphics.getHeight()/2 - love.graphics.getHeight()/3 ,love.graphics.getWidth()/2 - love.graphics.getHeight()/3,0,2,2);
		else
			if(PAUSED) then
				love.graphics.print({{255,0,0,},"PAUSED BY "..PAUSEDBY},love.graphics.getHeight()/3 ,love.graphics.getWidth()/3,0,2,2);
			end
		end
	end
end

function beginContact(a,b,coll)
	if(a:getUserData() == "P1H") then  --checking P1 hammer collision
		if((player1.hammer.isSwinging) and (CheckDeadzone(player1.controller.axisDir3,player1.controller.axisDir4,player1.controller.DEAD_ZONE_R))) then  --check if player is swinging
			braxSound:play()
			if(b:getUserData() == "P2") then --if colliding with P2, knock 'em back
				local px,py = CalculateImpulse(player1.rotSpeed,player1.hammer.rigidbody.b:getMass(),player1.hammer.xB,player1.hammer.yB,player1.hammer.xA,player1.hammer.yA); --calculate impulse
				b:getBody():applyLinearImpulse(px,py); --apply knockback
				player2.chp = dealDamage(px,py,player2.chp); --deal the damage
				player2.dead = checkDeath(player2.chp,player2.rigidbody.b); --check if player is dead
			end

			if(b:getUserData() == "P3") then --if colliding with P3, knock 'em back
				local px,py = CalculateImpulse(player1.rotSpeed,player1.hammer.rigidbody.b:getMass(),player1.hammer.xB,player1.hammer.yB,player1.hammer.xA,player1.hammer.yA); --calculate impulse
				b:getBody():applyLinearImpulse(px,py);  --apply knockback
				player3.chp = dealDamage(px,py,player3.chp);  --deal the damage
				player3.dead = checkDeath(player3.chp,player3.rigidbody.b); --check if player is dead
			end
			--add p4
		end
	end
	if(a:getUserData() == "P2H") then --checking P2 hammer collision
		if((player2.hammer.isSwinging) and (CheckDeadzone(player2.controller.axisDir3,player2.controller.axisDir4,player2.controller.DEAD_ZONE_R))) then
			braxSound:play()
			if(b:getUserData() == "P1") then
				local px,py = CalculateImpulse(player2.rotSpeed,player2.hammer.rigidbody.b:getMass(),player2.hammer.xB,player2.hammer.yB,player2.hammer.xA,player2.hammer.yA);
				b:getBody():applyLinearImpulse(px,py);
				player1.chp = dealDamage(px,py,player1.chp);
				player1.dead = checkDeath(player1.chp,player1.rigidbody.b);
			end

			if(b:getUserData() == "P3") then
				local px,py = CalculateImpulse(player2.rotSpeed,player2.hammer.rigidbody.b:getMass(),player2.hammer.xB,player2.hammer.yB,player2.hammer.xA,player2.hammer.yA);
				b:getBody():applyLinearImpulse(px,py);
				player3.chp = dealDamage(px,py,player3.chp);
				player3.dead = checkDeath(player3.chp,player3.rigidbody.b);
			end
		end
	end
	if(a:getUserData() == "P3H") then --checking P3 hammer collision
		if((player3.hammer.isSwinging) and (CheckDeadzone(player3.controller.axisDir3,player3.controller.axisDir4,player3.controller.DEAD_ZONE_R))) then
			braxSound:play()
			if(b:getUserData() == "P1") then
				local px,py = CalculateImpulse(player3.rotSpeed,player3.hammer.rigidbody.b:getMass(),player3.hammer.xB,player3.hammer.yB,player3.hammer.xA,player3.hammer.yA);
				b:getBody():applyLinearImpulse(px,py);
				player1.chp = dealDamage(px,py,player1.chp);
				player1.dead = checkDeath(player1.chp,player1.rigidbody.b);
			end

			if(b:getUserData() == "P2") then
				local px,py = CalculateImpulse(player3.rotSpeed,player3.hammer.rigidbody.b:getMass(),player3.hammer.xB,player3.hammer.yB,player3.hammer.xA,player3.hammer.yA);
				b:getBody():applyLinearImpulse(px,py);
				player2.chp = dealDamage(px,py,player2.chp);
				player2.dead = checkDeath(player2.chp,player2.rigidbody.b);
			end
		end
	end
end

function endContact(a,b,coll)
end

function preSolve(a,b,coll)
end

function postSolve(a,b,coll)
end

function love.quit()
	print("Goodbye!")
end
