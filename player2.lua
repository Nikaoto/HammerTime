function createP2()
  player2 = {
    hp = 100, chp = 100,  --total hp and current hp
    sp = 100, csp = 100,  --total stamina and current stamina
    x = 200, y = 200,  --position (x,y)
    dead = false, --dead or not
    ox,oy,  --origin x and y
    lx = 100, ly = 100, --look x and y
    lox = 5, loy = 5, --look crosshair origin x and y
    rot = 0,  --rotation
    time = 0, tend = 0, rotA = 0, rotB = 0, rotC = 0, --for calculating swing speed (rotAfter, rotBefore, rotChange)
    sprite = love.graphics.newImage("/res/bloq1.png"),  --loading player sprite
    Shader = love.graphics.newShader[[
      extern number setRed;
      extern number setGreen;
      extern number setBlue;
      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
      {
        //Getting current pixel color
        vec4 pixel = Texel(texture, texture_coords );
        //Checking if current pixel isn't the white direction line
        if(pixel.r == 1 && pixel.g != 1 && pixel.b !=1)
          {
            pixel.r = setRed;
            pixel.g = setGreen;
            pixel.b = setBlue;
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
      joystick = joysticks[2],  --which joystick belongs to to this player
      axisDir1,axisDir2,axisDir3,axisDir4, --axii
      SWING = 8,  --button for swing
      DASH = 7, --button for dash
      PAUSE = 10, --button for pause
      DEAD_ZONE_L = 0.23, --left axis deadzone
      DEAD_ZONE_R = 0.28  --right axis deadzone
    }
  };

  --setting player2 origin x and y
  player2.ox = player2.sprite:getWidth()/2;
  player2.oy = player2.sprite:getHeight()/2;

  --creating player2 rigidbody
  player2.rigidbody = {};
    player2.rigidbody.b = love.physics.newBody(world,player2.x,player2.y,"dynamic");
    player2.rigidbody.b:setMass(45);
    player2.rigidbody.s = love.physics.newCircleShape(player2.sprite:getWidth()/2);
    player2.rigidbody.f = love.physics.newFixture(player2.rigidbody.b,player2.rigidbody.s);
    player2.rigidbody.b:setLinearDamping(20);
    player2.rigidbody.b:setAngularDamping(10);
    player2.rigidbody.f:setUserData("P2"); --user data used for collision detection
  player2.hammer.rigidbody = {};
    player2.hammer.rigidbody.b = love.physics.newBody(world,player2.hammer.x,player2.hammer.y,"dynamic");
    player2.hammer.rigidbody.b:setMass(0);
    player2.hammer.rigidbody.s = love.physics.newRectangleShape(player2.hammer.sprite:getWidth(),player2.hammer.sprite:getHeight()); --hammer height = 25
    player2.hammer.rigidbody.f = love.physics.newFixture(player2.hammer.rigidbody.b,player2.hammer.rigidbody.s);
    player2.hammer.rigidbody.b:setLinearDamping(20);
    player2.hammer.rigidbody.b:setAngularDamping(10);
    player2.hammer.rigidbody.f:setUserData("P2H"); --user data used for collision detection

    --creating joint for hammer swinging
  player2.joint = love.physics.newFrictionJoint(player2.rigidbody.b, player2.hammer.rigidbody.b, player2.ox, player2.oy, player2.hammer.ox, player2.hammer.oy, false);
end

function P2Input()
  player2.controller.axisDir1, player2.controller.axisDir2, player2.controller.axisDir3, player2.controller.axisDir4 = player2.controller.joystick:getAxes();
end

function P2Rot() --finds the rotational speed of the hammer
  player2.time = love.timer.getTime();
  player2.rotA = math.rad(player2.rot);
  player2.hammer.xA = player2.hammer.x;
  player2.hammer.yA = player2.hammer.y;
  if(player2.time >= player2.tend) then
    player2.rotB = player2.rot;
    player2.rotC = player2.rotB - player2.rotA;
    player2.hammer.xB = player2.hammer.x;
    player2.hammer.yB = player2.hammer.y;
    player2.rotspeed = player2.rotC;
    player2.tend = player2.time + TICK;
  end
end

function P2Control()

    P2Rot();
  player2.hammer.x,player2.hammer.y = player2.hammer.rigidbody.b:getPosition();
  player2.hammer.rigidbody.b:setAngle(math.rad(player2.rot));
  --MOVEMENT for player2
  velx,vely = player2.rigidbody.b:getLinearVelocity();
  if (abs(player2.controller.axisDir1) > player2.controller.DEAD_ZONE_L) then  --checking deadzone
    player2.rigidbody.b:setLinearVelocity(player2.speed*player2.controller.axisDir1,vely);  --moving player
  end

  velx,vely = player2.rigidbody.b:getLinearVelocity();
  if (abs(player2.controller.axisDir2) > player2.controller.DEAD_ZONE_L) then  --checking deadzone
    player2.rigidbody.b:setLinearVelocity(velx,player2.speed*player2.controller.axisDir2);  --moving player
  end

  --LOOKING for player2
  if (abs(player2.controller.axisDir4) > player2.controller.DEAD_ZONE_R) then  --checking deadzone
    player2.lx = player2.x + player2.controller.axisDir4 * LOOK_ZONE; --moving crosshair
  else
    player2.lx = player2.x;
  end
  if (abs(player2.controller.axisDir3) > player2.controller.DEAD_ZONE_R) then  --checking deadzone
    player2.ly = player2.y + player2.controller.axisDir3 * LOOK_ZONE; --moving crosshair
  else
    player2.ly = player2.y;
  end


  --ROTATION for player2
  if (abs(player2.controller.axisDir4) > player2.controller.DEAD_ZONE_R or abs(player2.controller.axisDir3) > player2.controller.DEAD_ZONE_R) then  --checking dead zone
    player2.rot = math.angle(player2.x,player2.y,player2.lx,player2.ly);  --rotating player
  end

  --setting Hammer pos
  if(player2.hammer.isSwinging) then
    player2.hammer.rigidbody.b:setPosition((player2.x+player2.lx) / 2, (player2.y+player2.ly) / 2 );
  else
    player2.hammer.rigidbody.b:setPosition(player2.x,player2.y);
    --player2.hammer.
  end
  --setting player pos
  player2.x,player2.y = player2.rigidbody.b:getPosition();

  --setting player rigidbody pos
  player2.rigidbody.b:setPosition(testScreenCollision(player2.x,player2.y,player2.ox,player2.oy,player2.sprite:getWidth(), player2.sprite:getHeight()));
end

function P2Stamina(dt) --manages the stamina
  if(player2.hammer.isSwinging) then
    local sw = math.distance(player2.hammer.xB,player2.hammer.yB,player2.hammer.xA,player2.hammer.yA); --calculating distance for stamina loss
    player2.csp = player2.csp - sw/SWING_COST_MOD;
    if(player2.csp <=0) then
      player2.hammer.isSwinging = false;
    end
  else
    player2.csp = player2.csp + dt*SWINGCOST;
    if(player2.csp >=player2.sp) then
      player2.csp = player2.sp;
    end
  end
end

function drawP2()
  --apply shader for player colour
  love.graphics.setShader(player2.Shader);
  --draw player2
  love.graphics.draw(player2.sprite, player2.x, player2.y, math.rad(player2.rot),1,1,player2.ox,player2.oy);
  --draw player2 hammer
  if(player2.hammer.isSwinging) then
    love.graphics.draw(player2.hammer.sprite,player2.hammer.x,player2.hammer.y,player2.hammer.rigidbody.b:getAngle(),1,1,player2.hammer.ox,player2.hammer.oy);
  end
  love.graphics.setShader(); --remove shader
end
