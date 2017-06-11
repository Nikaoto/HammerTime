function createP3()
	player3 = {
		hp = 100, chp = 100,  --total hp and current hp
		sp = 100, csp = 100,  --total stamina and current stamina
		dead = false, --dead or not
		x = 300, y = 300,  --position (x,y)
		ox,oy,  --origin x and y
		lx = 100, ly = 100,	--look x and y
		lox = 5, loy = 5, --look crosshair origin x and y
		rot = 0,  --rotation
		time = 0, tend = 0, rotA = 0, rotB = 0, rotC = 0, --for calculating swing speed (rotAfter, rotBefore, rotChange)
		sprite = love.graphics.newImage("/res/bloq1.png"),  --loading player sprite
		Shader = love.graphics.newShader[[
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
		{
			vec4 pixel = Texel(texture, texture_coords);
			if(pixel.r == 1 && pixel.g != 1 && pixel.b != 1)
				{
					pixel.r = 0;
					pixel.g = 255;
					pixel.b = 0;
				}

			return pixel * color;
		}
		]],
		speed = MOVESPEED,  --do really need to explain what this is?
		rotspeed = 0,  --rotation speed of player
		hammer = {
			sprite = love.graphics.newImage("/res/hammer.png"),  --loading swinging sprite
			isSwinging = false,  --true if swinging, false if not
			x = 0, y = 0,  --position of swing (x,y)
			xB = 0, yB = 0, xA = 0, yA = 0, --for calculating swing speed
			ox = 20,
			oy = 25,
			timer = {
				start,
				time = 0.5
			}
		},
		controller = {
			joystick = joysticks[3],  --which joystick belongs to to this player 
			axisDir1,axisDir2,axisDir3,axisDir4, --axii
			SWING = 8,	--button for swing
			DASH = 7,	--button for dash
			PAUSE = 10, --button for pause
			DEAD_ZONE_L = 0.23,	--left axis deadzone 
			DEAD_ZONE_R = 0.28	--right axis deadzone
		}
	};

	--setting player3 origin x and y
	player3.ox = player3.sprite:getWidth()/2;
	player3.oy = player3.sprite:getHeight()/2;
	
	--creating player3 rigidbody
	player3.rigidbody = {};
		player3.rigidbody.b = love.physics.newBody(world,player3.x,player3.y,"dynamic");
		player3.rigidbody.b:setMass(45);
		player3.rigidbody.s = love.physics.newCircleShape(player3.sprite:getWidth()/2);
		player3.rigidbody.f = love.physics.newFixture(player3.rigidbody.b,player3.rigidbody.s);
		player3.rigidbody.b:setLinearDamping(20);
		player3.rigidbody.b:setAngularDamping(10);
		player3.rigidbody.f:setUserData("P3");
	player3.hammer.rigidbody = {};
		player3.hammer.rigidbody.b = love.physics.newBody(world,player3.hammer.x,player3.hammer.y,"dynamic");
		player3.hammer.rigidbody.b:setMass(0); 
		player3.hammer.rigidbody.s = love.physics.newRectangleShape(player3.hammer.sprite:getWidth(),player3.hammer.sprite:getHeight()); --hammer height = 25
		player3.hammer.rigidbody.f = love.physics.newFixture(player3.hammer.rigidbody.b,player3.hammer.rigidbody.s);
		player3.hammer.rigidbody.b:setLinearDamping(20);
		player3.hammer.rigidbody.b:setAngularDamping(10);
		player3.hammer.rigidbody.f:setUserData("P3H");
	player3.joint = love.physics.newFrictionJoint(player3.rigidbody.b, player3.hammer.rigidbody.b, player3.ox, player3.oy, player3.hammer.ox, player3.hammer.oy, false);
end

function P3Input()
	player3.controller.axisDir1, player3.controller.axisDir2, player3.controller.axisDir3, player3.controller.axisDir4 = player3.controller.joystick:getAxes();
end

function P3Rot() --finds the rotational speed of the hammer
	player3.time = love.timer.getTime();
	player3.rotA = math.rad(player3.rot);
	player3.hammer.xA = player3.hammer.x;
	player3.hammer.yA = player3.hammer.y;
	if(player3.time >= player3.tend) then
		player3.rotB = player3.rot;
		player3.rotC = player3.rotB - player3.rotA;
		player3.hammer.xB = player3.hammer.x;
		player3.hammer.yB = player3.hammer.y;
		player3.rotspeed = player3.rotC;
		player3.tend = player3.time + TICK;
	end
end

function P3Control()
	P3Rot();
	player3.hammer.x,player3.hammer.y = player3.hammer.rigidbody.b:getPosition();
	player3.hammer.rigidbody.b:setAngle(math.rad(player3.rot));
	--MOVEMENT for player3
	velx,vely = player3.rigidbody.b:getLinearVelocity();  --setting velocity
	if (abs(player3.controller.axisDir1) > player3.controller.DEAD_ZONE_L) then  --checking deadzone 
		player3.rigidbody.b:setLinearVelocity(player3.speed*player3.controller.axisDir1,vely);  --moving player
	end

	velx,vely = player3.rigidbody.b:getLinearVelocity();
	if (abs(player3.controller.axisDir2) > player3.controller.DEAD_ZONE_L) then  --checking deadzone
		player3.rigidbody.b:setLinearVelocity(velx,player3.speed*player3.controller.axisDir2);	--moving player
	end

	--LOOKING for player3
	if (abs(player3.controller.axisDir4) > player3.controller.DEAD_ZONE_R) then  --checking deadzone
		player3.lx = player3.x + player3.controller.axisDir4 * LOOK_ZONE;	--moving crosshair
	else
		player3.lx = player3.x;
	end
	if (abs(player3.controller.axisDir3) > player3.controller.DEAD_ZONE_R) then  --checking deadzone
		player3.ly = player3.y + player3.controller.axisDir3 * LOOK_ZONE;	--moving crosshair
	else
		player3.ly = player3.y;
	end


	--ROTATION for player3
	if (abs(player3.controller.axisDir4) > player3.controller.DEAD_ZONE_R or abs(player3.controller.axisDir3) > player3.controller.DEAD_ZONE_R) then  --checking dead zone
		player3.rot = math.angle(player3.x,player3.y,player3.lx,player3.ly);	--rotating player
	end
	--setting Hammer pos
	if(player3.hammer.isSwinging) then
		player3.hammer.rigidbody.b:setPosition((player3.x+player3.lx) / 2, (player3.y+player3.ly) / 2 );
	else
		player3.hammer.rigidbody.b:setPosition(player3.x,player3.y);
	end

	--setting player pos
	player3.x,player3.y = player3.rigidbody.b:getPosition();
	--setting player rigidbody position
	player3.rigidbody.b:setPosition(testScreenCollision(player3.x,player3.y,player3.ox,player3.oy,player3.sprite:getWidth(), player3.sprite:getHeight())); 
end

function P3Stamina(dt) --manages the stamina
	if(player3.hammer.isSwinging) then
		local sw = math.distance(player3.hammer.xB,player3.hammer.yB,player3.hammer.xA,player3.hammer.yA); --calculating distance for stamina loss
		player3.csp = player3.csp - sw/SWING_COST_MOD;
		if(player3.csp <=0) then
			player3.hammer.isSwinging = false;
		end
	else
		player3.csp = player3.csp + dt*SWINGCOST;
		if(player3.csp >=player3.sp) then
			player3.csp = player3.sp;
		end
	end
end

function drawP3()
	--apply shader first 
	love.graphics.setShader(player3.Shader);
	--draw player3
	love.graphics.draw(player3.sprite, player3.x, player3.y, math.rad(player3.rot),1,1,player3.ox,player3.oy);  
	--draw player3 hammer
		if(player3.hammer.isSwinging) then
			love.graphics.draw(player3.hammer.sprite,player3.hammer.x,player3.hammer.y,player3.hammer.rigidbody.b:getAngle(),1,1,player3.hammer.ox,player3.hammer.oy);  
		end
	love.graphics.setShader(); --remove shader
end