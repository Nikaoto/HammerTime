Controller = Object:extend()

function Controller:new(joystick)
  --Joystick that controls the player
  self.joystick = joystick

  --Table for button controls
  self.btn = {
    swing = 8,
    dash = 7,
    pause = 10
  }

  --Table for deadzones
  self.deadZone = {
    L = 0.23, --Left axis deadzone
    R = 0.28  --Right axis deadzone
  }
end

function Controller:getInput()
  self.axisDir1, self.axisDir2, self.axisDir3, self.axisDir4 = self.joystick:getAxes()

  
end
