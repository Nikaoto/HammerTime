bloomShader = love.graphics.newShader[[
  extern vec2 size;
  extern int top_limit;
  extern int bot_limit;
  extern int left_limit;
  extern int right_limit;
  extern int width = 5;
  vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
  {
  vec4 source = Texel(tex, tc);
  vec4 sum = vec4(0);
  int diff = (samples - 1) / 2;
  vec2 sizeFactor = vec2(1) / size * quality;

  for (int x = -diff; x <= diff; x++)
  {
    for (int y = -diff; y <= diff; y++)
    {
      vec2 offset = vec2(x, y) * sizeFactor;
      sum += Texel(tex, tc + offset);
    }
  }

  return ((sum / (samples * samples)) + source) * colour;
  }
]]

function updateBloomShader()
  bloomShader:send("size", {display.width, display.height})
  bloomShader:send("samples", 1)
  bloomShader:send("quality", 1)
end
