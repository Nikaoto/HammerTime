PlayerShader = Object:extend()

function PlayerShader:new(r, g, b, a)
  self.mainColor = {r, g, b, a or 255}
  print(r.." "..g.." "..b)
  self.shader = love.graphics.newShader[[
    extern vec4 mainColor; //Color to set
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {

      //Getting current pixel color
      vec4 pixel = Texel(texture, texture_coords );

      //Checking if current pixel isn't the white direction line
      if(pixel.r == 1 && pixel.g != 1 && pixel.b !=1) {
        pixel.r = mainColor.r;
        pixel.g = mainColor.g;
        pixel.b = mainColor.b;
      }
      return pixel * color;
    }]]
end

--Continiously send the mainColor
function PlayerShader:update()
  self.shader:sendColor("mainColor", self.mainColor)
end

function PlayerShader:getShader()
  return self.shader
end
