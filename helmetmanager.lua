helmetCount = 6
helmetImages = {}
function initHelmets()
  for i = 1, helmetCount do
    helmetImages[i] = love.graphics.newImage("/res/helmet"..i..".png")
  end
end
