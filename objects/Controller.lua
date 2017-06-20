Controller = Object:extend()

local s = {}

function Controller:new(joystick)
  --Metatable for shorter slef-reference
  s = setmetatable(s, self)
  self.__index = self

  --Joystick that controls the player
  s.joystick = joystick

  --Table for button controls
  s.btn = {
    swing = 8,
    dash = 7,
    pause = 10
  }

  --Table for deadzones
  s.deadZone = {
    L = 0.23, --Left axis deadzone
    R = 0.28  --Right axis deadzone
  }
end

function Controller:getInput()
  --Getting the axii
  s.axisDir1, s.axisDir2, s.axisDir3, s.axisDir4 = s.joystick:getAxes()

  --Moving invisible crosshair (used to calculate rotation angle)
  if (abs(s.axisDir3) > s.deadZone.R) then  --checking deadzone
    player1.ly = player1.y + s.axisDir3 * LOOK_ZONE;	--moving crosshair
  else
    player1.ly = player1.y;
  end

  if (abs(s.axisDir4) > s.deadZone.R) then  --checking deadzone
    player1.lx = player1.x + s.axisDir4 * LOOK_ZONE;	--moving crosshair
  else
    player1.lx = player1.x;
  end
end

--Gets the change in X coordinate from axis
function Controller:getMoveX()
  local dx = s.axisDir1
  if abs(dx) > s.deadZone.L then
    return dx
  else
    return 0
  end
end

--Gets the change in Y coordinate from axis
function Controller:getMoveY()
  local dy = s.axisDir2
  if abs(dy) > s.deadZone.L then
    return dy
  else
    return 0
  end
end

--Gets the change in looking X direction
function Controller:getLookX()
  local lx = s.axisDir4
  if abs(lx) > s.deadZone.R then
    return lx
  else
    return 0
  end
end

--Gets the change in looking Y direction
function Controller:getLookY()
  local ly = s.axisDir3
  if abs(ly) > s.deadZone.R then
    return ly
  else
    return 0
  end
end

--Gets rotation (if no rotation is occuring, returns the same value)
function Controller:getRotation(x, y, lx, ly, defaultRot)
  --Checking deadzones
  if abs(s.axisDir4) > s.deadZone.R or abs(s.axisDir3) > s.deadZone.R then
    return math.angle(x, y, lx, ly);
  end
  return defaultRot
end
