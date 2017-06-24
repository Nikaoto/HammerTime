Controller = Object:extend()

function Controller:new(joystick)
  --Joystick that controls the player
  self.joystick = joystick
  --Table for button controls
  self.btn = {
    swing = 6,
    dash = 7,
    pause = 10
  }

  --Table for deadzones
  self.deadZone = {
    L = 0.1, --Left axis deadzone
    R = 0.23  --Right axis deadzone
  }
end

function Controller:getInput()
  --Getting the axii
  self.axisDir1, self.axisDir2, self.axisDir3, self.axisDir4 = self.joystick:getAxes()
end

--Gets the change in X coordinate from axis
function Controller:getMoveX()
  local dx = self.axisDir1
  if abs(dx) > self.deadZone.L then
    return dx
  else
    return 0
  end
end

--Gets the change in Y coordinate from axis
function Controller:getMoveY()
  local dy = self.axisDir2
  if abs(dy) > self.deadZone.L then
    return dy
  else
    return 0
  end
end

--Gets the change in looking X direction
function Controller:getLookX()
  local lx = self.axisDir4
  if abs(lx) > self.deadZone.R then
    return lx
  else
    return 0
  end
end

--Gets the change in looking Y direction
function Controller:getLookY()
  local ly = self.axisDir3
  if abs(ly) > self.deadZone.R then
    return ly
  else
    return 0
  end
end

--Gets rotation (if no rotation is occuring, returns the same value)
function Controller:getRotation(x, y, lx, ly)
  --Checking deadzones
  if abs(self.axisDir4) > self.deadZone.R or abs(self.axisDir3) > self.deadZone.R then
    return math.angle(x, y, lx, ly);
  end
end

function Controller:passedDeadZone(axis, deadzone)
	return abs(axis) > deadzone
end

function Controller:checkSwingBtn()
    return self.joystick:isDown(self.btn.swing)
end

function Controller:checkDashBtn()
    return self.joystick:isDown(self.btn.dash)
end

function Controller:checkPauseBtn()
  return self.joystick:isDown(self.btn.pause)
end

function Controller:getJoystick()
  return self.joystick
end
