function createP1()
	player1 = {
		hp = 100, chp = 100,  --total hp and current hp
		sp = 100, csp = 100,  --total stamina and current stamina
		dead = false, --dead or not
		x = 100, y = 100,  --position (x,y)
		ox,oy,  --origin x and y
		lx = 100, ly = 100,	--look x and y
		lox = 5, loy = 5, --look crosshair origin x and y
		rot = 0,  --rotation
		time = 0, tend = 0, rotA = 0, rotB = 0, rotC = 0, --for calculating swing speed (rotAfter, rotBefore, rotChange)
		sprite = love.graphics.newImage("/res/bloq1.png"),  --loading player sprite
		speed = MOVESPEED,  --do really need to explain what this is?
		rotspeed = 0,  --rotation speed of player
		hammer = {
			sprite = love.graphics.newImage("/res/hammer.png"),  --loading swinging sprite
			isSwinging = false,  --true if swinging, false if not
			x = 0, y = 0,  --position of swing (x,y)d
			xB = 0, yB = 0, xA = 0, yA = 0, --for calculating swing speed
			ox = 20,
			oy = 25,
			timer = {
				start,
				time = 0.5
			}
		},
		controller = {
			joystick = joysticks[1],  --which joystick belongs to to this player 
			axisDir1,axisDir2,axisDir3,axisDir4, --axii
			SWING = 8,	--button for swing
			DASH = 7,	--button for dash
			PAUSE = 10, --button for pause
			DEAD_ZONE_L = 0.23,	--left axis deadzone 
			DEAD_ZONE_R = 0.28	--right axis deadzone
		}
	};

	--setting player1 origin x and y
	player1.ox = player1.sprite:getWidth()/2;
	player1.oy = player1.sprite:getHeight()/2;
	
	--creating player1 rigidbody
	player1.rigidbody = {};
		player1.rigidbody.b = love.physics.newBody(world,player1.x,player1.y,"dynamic");
		player1.rigidbody.b:setMass(45);
		player1.rigidbody.s = love.physics.newCircleShape(player1.sprite:getWidth()/2);
		player1.rigidbody.f = love.physics.newFixture(player1.rigidbody.b,player1.rigidbody.s);
		player1.rigidbody.b:setLinearDamping(20);
		player1.rigidbody.b:setAngularDamping(10);
		player1.rigidbody.f:setUserData("P1");
	player1.hammer.rigidbody = {};
		player1.hammer.rigidbody.b = love.physics.newBody(world,player1.hammer.x,player1.hammer.y,"dynamic");
		player1.hammer.rigidbody.b:setMass(0); 
		player1.hammer.rigidbody.s = love.physics.newRectangleShape(player1.hammer.sprite:getWidth(),player1.hammer.sprite:getHeight()); --hammer height = 25
		player1.hammer.rigidbody.f = love.physics.newFixture(player1.hammer.rigidbody.b,player1.hammer.rigidbody.s);
		player1.hammer.rigidbody.b:setLinearDamping(20);
		player1.hammer.rigidbody.b:setAngularDamping(10);
		player1.hammer.rigidbody.f:setUserData("P1H");
	player1.joint = love.physics.newFrictionJoint(player1.rigidbody.b, player1.hammer.rigidbody.b, player1.ox, player1.oy, player1.hammer.ox, player1.hammer.oy, false);
end

function P1Input()
	player1.controller.axisDir1, player1.controller.axisDir2, player1.controller.axisDir3, player1.controller.axisDir4 = player1.controller.joystick:getAxes();
end

function P1Rot() --finds the rotational speed of the hammer
	player1.time = love.timer.getTime();
	player1.rotA = math.rad(player1.rot);
	player1.hammer.xA = player1.hammer.x;
	player1.hammer.yA = player1.hammer.y;
	if(player1.time >= player1.tend) then
		player1.rotB = player1.rot;
		player1.rotC = player1.rotB - player1.rotA;
		player1.hammer.xB = player1.hammer.x;
		player1.hammer.yB = player1.hammer.y;
		player1.rotspeed = player1.rotC;
		player1.tend = player1.time + TICK;
	end
end

function P1Control()
	P1Rot();
	player1.hammer.x,player1.hammer.y = player1.hammer.rigidbody.b:getPosition();
	player1.hammer.rigidbody.b:setAngle(math.rad(player1.rot));
	--MOVEMENT for Player1
	velx,vely = player1.rigidbody.b:getLinearVelocity();  --setting velocity
	if (abs(player1.controller.axisDir1) > player1.controller.DEAD_ZONE_L) then  --checking deadzone 
		player1.rigidbody.b:setLinearVelocity(player1.speed*player1.controller.axisDir1,vely);  --moving player
	end

	velx,vely = player1.rigidbody.b:getLinearVelocity();
	if (abs(player1.controller.axisDir2) > player1.controller.DEAD_ZONE_L) then  --checking deadzone
		player1.rigidbody.b:setLinearVelocity(velx,player1.speed*player1.controller.axisDir2);	--moving player
	end

	--LOOKING for Player1
	if (abs(player1.controller.axisDir4) > player1.controller.DEAD_ZONE_R) then  --checking deadzone
		player1.lx = player1.x + player1.controller.axisDir4 * LOOK_ZONE;	--moving crosshair
	else
		player1.lx = player1.x;
	end
	if (abs(player1.controller.axisDir3) > player1.controller.DEAD_ZONE_R) then  --checking deadzone
		player1.ly = player1.y + player1.controller.axisDir3 * LOOK_ZONE;	--moving crosshair
	else
		player1.ly = player1.y;
	end


	--ROTATION for Player1
	if (abs(player1.controller.axisDir4) > player1.controller.DEAD_ZONE_R or abs(player1.controller.axisDir3) > player1.controller.DEAD_ZONE_R) then  --checking dead zone
		player1.rot = math.angle(player1.x,player1.y,player1.lx,player1.ly);	--rotating player
	end
	--setting Hammer pos
	if(player1.hammer.isSwinging) then
		player1.hammer.rigidbody.b:setPosition((player1.x+player1.lx) / 2, (player1.y+player1.ly) / 2 );
	else
		player1.hammer.rigidbody.b:setPosition(player1.x,player1.y);
	end

	--setting player pos
	player1.x,player1.y = player1.rigidbody.b:getPosition();
	--setting player rigidbody position
	player1.rigidbody.b:setPosition(testScreenCollision(player1.x,player1.y,player1.ox,player1.oy,player1.sprite:getWidth(), player1.sprite:getHeight())); 
end

function P1Stamina(dt) --manages the stamina
	if(player1.hammer.isSwinging) then
		local sw = math.distance(player1.hammer.xB,player1.hammer.yB,player1.hammer.xA,player1.hammer.yA); --calculating distance for stamina loss
		player1.csp = player1.csp - sw/SWING_COST_MOD;
		if(player1.csp <=0) then
			player1.hammer.isSwinging = false;
		end
	else
		player1.csp = player1.csp + dt*SWINGCOST;
		if(player1.csp >=player1.sp) then
			player1.csp = player1.sp;
		end
	end
end

function drawP1()
	--draw player1
	love.graphics.draw(player1.sprite, player1.x, player1.y, math.rad(player1.rot),1,1,player1.ox,player1.oy);  
	--draw Player1 hammer
		if(player1.hammer.isSwinging) then
			love.graphics.draw(player1.hammer.sprite,player1.hammer.x,player1.hammer.y,player1.hammer.rigidbody.b:getAngle(),1,1,player1.hammer.ox,player1.hammer.oy);  
		end
end