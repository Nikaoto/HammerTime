cloudImageCount = 6
cloudImages = {}
local x1, x2, x3 = 0, display.width - 200, 300
function initClouds()
  for i = 1, cloudImageCount do
    cloudImages[i] = love.graphics.newImage("/res/cloud"..i..".png")
  end
end

function drawClouds()
  love.graphics.draw(cloudImages[1], x1, 1)
  love.graphics.draw(cloudImages[2], x2, 400)
  love.graphics.draw(cloudImages[3], x3, display.height - 400)
end

function updateClouds(dt)
  x1 = x1 + dt * 10
  x2 = x2 - dt * 20
  x3 = x3 + dt * 17
end
