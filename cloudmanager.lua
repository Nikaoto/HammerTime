cloudImages = {}
cloudImages.count = 6

function initClouds()
  for i = 1, cloudImages.count do
    cloudImages[i] = love.graphics.newImage("/res/cloud"..i..".png")
  end
end

function drawClouds()

end

function updateClouds(dt)

end
