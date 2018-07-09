--[[
local dir = love.filesystem.getWorkingDirectory()..'/fonts'
dir = "fonts"
local files = love.filesystem.getDirectoryItems(dir)

print('files:', #files)
for i,v in ipairs(files) do
  print('File '..tostring(i)..': '..v)
end
print()

function output(name)
  local result = love.filesystem[name]()
  print(tostring(name)..': '..tostring(result))
end

local funcs = { "getAppdataDirectory", "getIdentity", "getSaveDirectory", "getSource",
  "getSourceBaseDirectory", "getUserDirectory", "getWorkingDirectory"
  }

for i,v in ipairs(funcs) do
  print(i,v)
  output(v)
end

--]]

major, minor, revision, codename = love.getVersion( )
print(string.format("LOVE version %s.%s.%s.%s", tostring(major), tostring(minor), tostring(revision), tostring(codename)))

local love = love
console = require('console')

GAMESTATE = {}
ASSETS = { sounds = {} }
ASSETS.sounds.option_change = love.audio.newSource("sounds/option_change.wav", "static")
ASSETS.sounds.option_select = love.audio.newSource("sounds/option_select.wav", "static")

local gs = GAMESTATE

gs.scenes = {
  loading = require("scenes/loading-scene"),
  display = require("scenes/display-scene")
}

local scenes = gs.scenes
gs.currentScene = scenes.loading
defaultFont = love.graphics.newFont(30)

local font = defaultFont
love.graphics.setFont(font)

local frames = {}
local frameIndex = 1
local frameTotal = 0
local frameCount = 0
local framesPerSecond = 0

function love.load()
  --require("mobdebug").start() -- for zerobrane
  
  --console.load(love.graphics.newFont(14))
  console.load(love.graphics.newFont('assets/fonts/Inconsolata.otf', 16))
  console.defineCommand("hello", "Print 'Hello, World!'.", function()
      console.i("Hello, World!")
      for i,v in ipairs(console.history) do
        print('History '..tostring(i)..': '..tostring(v))
      end
      print('historyPosition: '..tostring(console.historyPosition))
      
    end)
  
  love.keyboard.setKeyRepeat(true)
end


function love.update(time)
  console.update(time)
  
  if gs.currentScene then gs.currentScene:update(time) end
  --[[
  dt = time
  local old = frames[frameIndex]
  if old ~= nil then frameTotal = frameTotal - old end
  frameTotal = frameTotal + time
  frames[frameIndex] = time
  frameIndex = frameIndex + 1
  if frameIndex > 60 then frameIndex = 1 end
  if frameCount < 60 then frameCount = frameCount + 1 end
  if frameCount >= 60 then
    framesPerSecond = 60 / frameTotal -- 60 frames per how many seconds?
  end
  --]]
end

local state = {
  topIndex = 1,
  selectedIndex = 1,
  fonts = {},
  isLoaded = false
}

function love.draw()
  if gs.currentScene and gs.currentScene.draw then gs.currentScene:draw() end
  
  --[[
  
  love.graphics.setColor(0, 0.4, 0.4)
  love.graphics.rectangle("fill", 50, 50, love.graphics.getWidth() - 100, love.graphics.getHeight() - 100)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format('Hello, world!  Font Height: %d', font:getHeight()), 100, 100)
  
  local height = love.graphics.getHeight() - 100 - 50 - 200 -- 100 for box border, 50 for bottom border in box, 200 for y start of text
  love.graphics.rectangle("line", 100, 200, 200, height)
  
  local text = "Mary had a little lamb, it's fleece as white as snow.  Everywhere that Mary went,\n the lamb was sure to go!  The quick brown fox jumped over the lazy sleeping dog.  0123456789  0O 1l"
  
  love.graphics.printf(text, 100, 200, 200, "center")
  
  dt = dt or 0
  
  local tbl = {
    {1, 0, 0}, "This is RED, ",
    {0, 1, 0}, "this is GREEN, ",
    {0, 0, 1}, "this is BLUE!\n",
    {0, 0, 0, 1}, "This is black at 100% alpha\n",
    {0, 0, 0, 0.75}, "This is black at 75% alpha\n",
    {0, 0, 0, 0.5}, "This is black at 50% alpha\n",
    {0, 0, 0, 0.25}, "This is black at 25% alpha\n",
    {0, 0, 0}, string.format("dt is: %0.3f\n", dt),
    {0, 0, 0}, string.format("FPS: %0.1f\n", framesPerSecond)
  }
  
  love.graphics.printf(tbl, 400, 200, 800, "center")
  --]]
  
  console.draw()
end

function love.keypressed(key, scancode, isrepeat)
  --print('key: '..tostring(key)..', scancode: '..tostring(scancode)..', isrepeat: '..tostring(isrepeat))
  
  if console.keypressed(key) then return end
  
  if gs.currentScene and gs.currentScene.keypressed then
    print('Has key repeat?', tostring(love.keyboard.hasKeyRepeat()))
    gs.currentScene:keypressed(key, scancode, isrepeat)
    return
  end
  
  
  if key == 'w' or key == 's' or key == 'down' or key == 'up' then
    ASSETS.sounds.option_change:play()
    return
  end
  if key == 'd' or key == 'space' then
    ASSETS.sounds.option_select:play()
    return
  end
  
end

function love.textinput(t)
  --print('textinput:', t)
  console.textinput(t)
end

function love.resize(w,h)
  console.resize(w,h)
end

function love.mousepressed(x,y,button)
  if console.mousepressed(x,y,button) then return end
end
