local Fonts = require('fonts')

local GS = GAMESTATE
local love = love
local graphics = love.graphics

local LINE_HEIGHT = 50

local bgNormal = { r=0,g=0,b=0,a=1 }
local fgNormal = { r=1,g=1,b=1,a=1 }
local fgSelected = bgNormal
local bgSelected = fgNormal

local scene = {
  keymap = {
    ["escape"] = "quit",
    ["down"] = "down",
    ["up"] = "up",
    ["pagedown"] = "pagedown",
    ["pageup"] = "pageup",
  },
  topIndex = 0, -- 0 based
  selectedIndex = 0, -- 0 based
  lines = 5,
  selected = nil,
  selectedSizes = {}
}

function scene:selectFont()
  local font = Fonts.list[self.selectedIndex + 1]
  
  -- is font really different?
  if self.selected == font then return end

  -- free last font
  for i,ss in ipairs(self.selectedSizes) do ss.font:release() end
  scene.selectedSizes = {}
  
  self.selected = font
  
  local pixelSizes = { 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72, 80, 100, 120 }
  local sizes = {}
  for i,pixels in ipairs(pixelSizes) do
    local points = math.floor(pixels / font.pointsPerPixel)
    local actualFont = love.graphics.newFont(font.fileData, points)
    local height = actualFont:getHeight()
    local size = {
      pixelHeight = pixels,
      height = height,
      points = points,
      font = actualFont,
      message = string.format("%d points", points)
    }
    table.insert(scene.selectedSizes, size)
  end
end

function scene:draw()
  -- first we clear the background
  graphics.clear()

  -- draw a rectangle
  graphics.setColor(0,0,0)
  graphics.rectangle("fill", 50, 50, love.graphics.getWidth() - 100, love.graphics.getHeight() - 100)
  
  local lines = math.floor((love.graphics.getHeight() - 100) / LINE_HEIGHT)
  self.lines = lines
  local top = 50
  local width = math.min(400, Fonts.maxWidth + 4)
    
  -- adjust topIndex so selectedIndex is always visible
  -- should be small enough so that final index is at the bottom, if there are enough
  self.topIndex = math.max(0, math.min(#Fonts.list - lines, self.topIndex))
  -- has to be big enough so that selected index will appear
  self.topIndex = math.max(self.topIndex, self.selectedIndex + 1 - lines)
  -- has to be less than selected index
  self.topIndex = math.min(self.topIndex, self.selectedIndex)
  
  --[[
  -- ok, draw up to 'lines' elements
  if (drawCount % 120) == 1 then
    print("drawCount: "..tostring(drawCount)..', Fonts is: '..tostring(Fonts))
    print(string.format("selectedIndex: %d, topIndex: %d, lines: %d, list length: %d", self.selectedIndex, self.topIndex, lines, #Fonts.list))
  end
  --]]
  
  for i = 0,math.min(lines - 1, #Fonts.list - 1) do
    local font = Fonts.list[i + self.topIndex + 1]

    local x = 0
    local y = top + i * LINE_HEIGHT
    local fg = fgNormal
    local bg = bgNormal
    if i + self.topIndex == self.selectedIndex then
      fg = fgSelected
      bg = bgSelected
    end

    graphics.setColor(bg.r, bg.g, bg.b, bg.a)
    graphics.rectangle("fill", x, y, width, LINE_HEIGHT)
    graphics.setColor(fgNormal.r, fgNormal.g, fgNormal.b, fgNormal.a)
    graphics.rectangle("line", x, y, width, LINE_HEIGHT)
    graphics.setFont(font.font)
    
    graphics.setScissor(x+1, y+1, width-2, LINE_HEIGHT-2)
    graphics.setColor(fg.r, fg.g, fg.b, fg.a)
    graphics.printf(font.name, x, y + font.offset, width, 'center')
    graphics.setScissor()
  end
  
  ----------------------------------------------------------------------
  -- now for selected font, draw on right
  ----------------------------------------------------------------------
  
  -- first we 'select' the font, which will release the old one and
  -- setup the 'Font' at various sizes for the new one
  self:selectFont()
  
  -- first the points (to hit 44 height goal) and font name
  local left = width + 10
  top = 50
  width = graphics.getWidth() - 50 - left
  graphics.setColor(1, 1, 1, 1)
  graphics.setScissor(left, top, width, 50)
  graphics.setFont(self.selected.font)
  graphics.print(string.format("%d pt: %s", self.selected.points, self.selected.name), left + 20, top, 0, 1, 1, 0, 0, -0.2, 0)
  graphics.setScissor()
  
  -- now various sizes
  graphics.setColor(0.6, 0.5, 0.9, 1)
  top = 120
  for i,ss in ipairs(self.selectedSizes) do
    graphics.setFont(ss.font)
    graphics.print(ss.message, left, top)
    top = top + ss.height + 10
  end
  
  -- now wrapped text
  top = 120
  left = math.min(left + 300, graphics.getWidth() - 50 - 20 - 300)
  width = love.graphics.getWidth() - 50 - left
  
  -- draw transparent black, in case overlapping with sizes earlier
  graphics.setColor(0,0,0,0.7)
  graphics.rectangle('fill', left, top, width, graphics.getHeight() - top - 50)
  graphics.setColor(1,1,1,0.7)
  graphics.rectangle('line', left, top, width, graphics.getHeight() - top - 50)
  graphics.setColor(0.8,0.8,1,0.8)
  graphics.setFont(self.selected.font)
  local message = [[The quick brown fox jumped over the lazy sleeping dog.
~0123456789
`!@#$%^&*()[]{}
;:'",<.>/?\|
zero is 0, oh is O 0O
one is 1, ell is l 1l]]
  graphics.printf(message, left + 10, top + 10, graphics.getWidth() - 50 - left - 20, 'left')
end

function scene:update(dt)
  --if GS.current == nil then scene:init() end
  
  for n, a, b, c, d, e, f in love.event.poll() do
    if n == "quit" then
      os.exit()
      return
    end
  end
end

function scene:keypressed(key, scancode, isrepeat)
  local event = self.keymap[key]
  
  if event == 'quit' then os.exit() end
  
  if event == 'down' then
    love.audio.stop()
    ASSETS.sounds.option_change:play()
    self.selectedIndex = (self.selectedIndex + 1) % #Fonts.list
    return
  end
  
  if event == 'up' then
    love.audio.stop()
    ASSETS.sounds.option_change:play()
    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex < 0 then self.selectedIndex = #Fonts.list - 1 end
    return
  end
  
  if event == 'pageup' then
    love.audio.stop()
    ASSETS.sounds.option_select:play()
    if self.selectedIndex == 0 then
      self.selectedIndex = #Fonts.list - 1
      return
    end
    self.selectedIndex = math.max(0, self.selectedIndex - self.lines)
    self.topIndex = self.topIndex - self.lines
    return
  end
  
  if event == 'pagedown' then
    love.audio.stop()
    ASSETS.sounds.option_select:play()
    if self.selectedIndex == #Fonts.list - 1 then
      self.selectedIndex = 0
      return
    end
    self.selectedIndex = math.min(#Fonts.list - 1, self.selectedIndex + self.lines)
    self.topIndex = self.topIndex + self.lines
    return
  end
  
end


return scene
