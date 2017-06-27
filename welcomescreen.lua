require 'cloudmanager'
local TAU = math.pi * 2
local screenWidth, screenHeight = display.width, display.height
--local screenWidth, screenHeight = love.graphics:getDimensions()
local canvas
local particleSystem
local MS = 1
local PSIZE = 40

function loadWelcomeScreen()
  titleImage = love.graphics.newImage("/res/title.png")

  love.graphics.setDefaultFilter('linear', 'linear', 4)

  --local p = love.graphics.newImage "particle.png"

  canvas = love.graphics.newCanvas(PSIZE, PSIZE)

  canvas:renderTo(function()
    --love.graphics.clear(255,255,255,0)
    --love.graphics.rectangle('fill', 0, 0, PSIZE, PSIZE)
    --love.graphics.circle('fill', PSIZE/2, PSIZE/2, PSIZE/2-2, 100)
    love.graphics.polygon('fill', 1, 16, 30, 16, 16, 1)
  end)

  --canvas = love.graphics.newImage "particle.png"
  particleSystem = love.graphics.newParticleSystem(canvas, 4096)
  particleSystem:setParticleLifetime(0.1, 1.9)
  particleSystem:setEmissionRate(850)
  particleSystem:setSizes(1.5, 0.6)
  particleSystem:setLinearAcceleration(-10, -10, 10, 10)
  particleSystem:setLinearDamping(3)
  particleSystem:setAreaSpread('uniform', screenWidth / 2, 0)
  particleSystem:setDirection(math.pi * 3 / 2)
  particleSystem:setPosition(screenWidth/2, screenHeight + 5)
  particleSystem:setSpeed(700, 410)
	particleSystem:setColors(255, 190, 130, 200,   255, 80, 0, 130,  0, 0, 0, 0)
  canvas = love.graphics.newCanvas(screenWidth * MS, screenHeight * MS)
end

function updateWelcomeScreen(dt)
  updateClouds(dt)
  particleSystem:update(dt)
end

function drawWelcomeScreen()
  drawSky(skyBG2)
  drawClouds()

  canvas:renderTo(function()
    --love.graphics.clear(0,0,0,0.01)
    love.graphics.setBlendMode('subtract', 'premultiplied')
    love.graphics.setColor(4, 20, 1, 10)
    love.graphics.rectangle('fill', 0, 0, screenWidth * MS, screenHeight * MS)

    love.graphics.setColor(255,255,255,255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(particleSystem)
  end)

  love.graphics.setBlendMode('alpha', 'alphamultiply')
  love.graphics.setColor(255,255,255,255)
  love.graphics.draw(canvas, 0, 0, 0, 1/MS, 1/MS)

--draw PRESS ANY KEY TO START GAME
  love.graphics.draw(titleImage, (display.width - titleImage:getWidth()) / 2, display.height/10)
end
