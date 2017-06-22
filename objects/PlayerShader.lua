PlayerShader = Object:extend()

--Creating s metatable for shorter self reference
local s ={}
function PlayerShader:setSelf()
  s = setmetatable(s, self)
  self.__index = self
end
--

local mainColor = {0, 0, 0, 0}
function PlayerShader:new(r, g, b, a)
  self:setSelf()
  mainColor = {r, g, b, a or 255}
  s.shader = love.graphics.newShader[[
    extern vec4 mainColor; //Color to set
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {

      //Getting current pixel color
      vec4 pixel = Texel(texture, texture_coords );

      //Checking if current pixel isn't the white direction line
      if(pixel.r == 1 && pixel.g != 1 && pixel.b !=1) {
        pixel = mainColor
      }
      return pixel * color;
    }]]
end

--Continiously send the mainColor
function PlayerShader:update()
  s.shader:sendColor("mainColor", mainColor)
end
