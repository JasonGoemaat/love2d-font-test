local sampleFont = love.graphics.newFont(30)
love.graphics.setFont(sampleFont)

local Fonts = require('fonts')

print('loading-scene.lua Fonts is: '..tostring(Fonts))

local gs = GAMESTATE
gs.Fonts = Fonts

local love = love
local graphics = love.graphics
local tau = math.pi * 2
local scene = {
  haveList = false, -- to get directory list first update
  fileNames = {},   -- to store names
  loadedCount = 0,  -- for displaying progress
  first = true,     -- so we don't 'update' the first time and can draw once
  message = 'Hello, world!'
}

print('UPDATED')

--[[ Generic spinner class --]]
local MySpinner = {}

function MySpinner.new()
  local obj = { totalTime = 0, slice = 0  }
  setmetatable(obj, { __index = MySpinner })
  return obj
end

function MySpinner:update(dt)
  self.totalTime = self.totalTime + dt
  self.slice = math.floor((self.totalTime * 12) % 12) -- goes through 0-11 in 1 second
end
function MySpinner:draw(x, y, radius)
  for i = 0,11 do
    local f = ((12 + i - self.slice) % 12) / 11
    graphics.setColor(f, f, f)
    local a = tau * (i / 12)
    local b = tau * ((i + 1) / 12)
    graphics.arc("fill", x, y, radius, a, b)
    graphics.setColor(0, 0, 0)
    graphics.arc("line", x, y, radius, a, b)
  end
end

scene.spinner = MySpinner.new()

function scene:draw()
  -- first we clear the background
  graphics.clear()

  -- and draw the spinner
  local midx = love.graphics.getWidth() / 2
  local midy = love.graphics.getHeight() / 2
  self.spinner:draw(midx, midy + 50, 50)
  
  love.graphics.setColor(1, 1, 1)
  graphics.printf({ {0.4, 0.4, 1}, self.message }, midx - 300, midy - defaultFont:getHeight() - 20, midx + 300, 'left')
end

function scene:update(dt)
  -- update the spinner
  self.spinner:update(dt)
  
  -- no update first run so we draw the screen
  if self.first then
    self.first = false
    self.message = 'Listing files in "fonts" directory...'
    return
  end
  
  -- get directory list if we don't have it
  if not self.haveList then
    local contents = love.filesystem.getDirectoryItems("fonts")
    self.fileNames = {}
    for i,file in ipairs(contents) do
      local a,b = file:find('%.[^%.]*$')
      if a ~= nil then
        local ext = file:sub(a, b)
        if ext:lower() == ".ttf" or ext:lower() == ".otf" then
          --print('Adding font file: "'..file..'"')
          table.insert(self.fileNames, file)
        else
          print('********* NOT A TTF FILE: "'..file..'" **********')
        end
      end
    end
    self.haveList = true
    return
  end
  
  if self.loadedCount >= #self.fileNames then
    GAMESTATE.currentScene = GAMESTATE.scenes.display
  end
  
  -- load a single file
  self.loadedCount = self.loadedCount + 1
  local fileName = self.fileNames[self.loadedCount]
  if fileName ~= nil then
    --print("Loading file "..self.loadedCount.." named "..tostring(fileName))
    Fonts.add(fileName)
    self.message = string.format("Loaded (%d of %d) '%s' ", self.loadedCount, #self.fileNames, fileName)
  end
end


return scene
