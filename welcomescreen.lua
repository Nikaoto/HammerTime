local TAU = math.pi * 2
local screenWidth, screenHeight = display.width, display.height
--local screenWidth, screenHeight = love.graphics:getDimensions()
local p, pe

local MS = 1
local PSIZE = 40

function loadWelcomeScreen()
  titleImage = love.graphics.newImage("/res/title.png")

  love.graphics.setDefaultFilter('linear', 'linear', 4)

  --local p = love.graphics.newImage "particle.png"

  p = love.graphics.newCanvas(PSIZE, PSIZE)

  p:renderTo(function()
    --love.graphics.clear(255,255,255,0)
    --love.graphics.rectangle('fill', 0, 0, PSIZE, PSIZE)
    --love.graphics.circle('fill', PSIZE/2, PSIZE/2, PSIZE/2-2, 100)
    love.graphics.polygon('fill', 1, 16, 30, 16, 16, 1)
  end)

  --p = love.graphics.newImage "particle.png"

  --love.graphics.setBackgroundColor(9, 25, 27)

  pe = {}
  for i=1,2 do
    pe[i] = love.graphics.newParticleSystem(p, 4096)
    pe[i]:setParticleLifetime(0.1, 1.9)
    pe[i]:setEmissionRate(850)
    pe[i]:setSizes(1.5, 0.6)
    --pe:setSizeVariation(1)
    pe[i]:setLinearAcceleration(-10, -10, 10, 10) -- Random movement in all directions.
    pe[i]:setLinearDamping(3)
    --pe:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
    pe[i]:setAreaSpread('uniform', screenWidth / 2, 0)
    --pe:setDirection(3/4 * TAU)
    --pe[i]:setRotation(0, TAU/4)
    pe[i]:setDirection(math.pi * 3 / 2)
  end
  pe[1]:setPosition(screenWidth/2, screenHeight)
  pe[2]:setPosition(screenWidth/2, screenHeight)

  pe[1]:setSpeed(700, 410)
  --pe[2]:setSpeed(-150, 0)

	pe[1]:setColors(255, 190, 130, 200,   255, 80, 0, 130,  0, 0, 0, 0)
	pe[2]:setColors(150, 255, 255, 200,   0, 255, 0, 130,   0, 0, 0, 0)

  canvas = love.graphics.newCanvas(screenWidth * MS, screenHeight * MS)
end


function updateWelcomeScreen(dt)
  for i=1,2 do pe[i]:update(dt) end
end

function drawWelcomeScreen()
  drawSky()
  canvas:renderTo(function()
    --love.graphics.clear(0,0,0,0.01)
    love.graphics.setBlendMode('subtract', 'premultiplied')
    love.graphics.setColor(4, 20, 1, 10)
    love.graphics.rectangle('fill', 0, 0, screenWidth * MS, screenHeight * MS)

    love.graphics.setColor(255,255,255,255)
    --love.graphics.setColor(255,0,255,255)
    --love.graphics.setColor(HSL(h, 200, 200, 255))
    love.graphics.setBlendMode('alpha', 'premultiplied')
    --for i=1,2 do love.graphics.draw(pe[i]) end
    love.graphics.draw(pe[1])
  end)

  love.graphics.setBlendMode('alpha', 'alphamultiply')
  love.graphics.setColor(255,255,255,255)
  --love.graphics.draw(pe)
  love.graphics.draw(canvas, 0, 0, 0, 1/MS, 1/MS)

--draw PRESS ANY KEY TO START GAME
  love.graphics.draw(titleImage,
    (display.width - titleImage:getWidth()) / 2, 100)
end
