gameTitle = "HammerTime"

display = {
  width = 1366,
  height = 768,
  settings = {
    fullscreen = false,
    resizable = false,
    vsync = true,
    borderless = false,
    centered = true,
    display = 1,
    console = false
  }
}

function love.conf(t)
  t.window.title = gameTitle
  --t.window.icon =
  t.window.width = display.width
  t.window.height = display.height
  t.window.vsync = display.settings.vsync
  t.window.borderless = display.settings.borderless
  t.window.resizable = display.settings.resizable
  t.window.fullscreen = display.settings.fullscreen
  t.console = display.settings.console
end
