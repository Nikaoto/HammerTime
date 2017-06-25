cloutImageCount = 6
cloudImages = {}

function initClouds()
  for i = 1, cloudImageCount do
    cloudImages[i] = love.graphics.newImage("/res/cloud"..i..".png")
  end
end

function drawClouds()

end

function updateClouds(dt)

end
