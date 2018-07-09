
local LINE_HEIGHT = 50
local MAX_FONT_HEIGHT = 44

local Fonts = {
  list = {},
  byName = {},
  maxWidth = 0
}

-- load font, scaling so it is <= 45 pixels height
function Fonts.add(fileName)
  local fullPath = 'fonts/'..fileName
  local obj = { fileName = fileName, fullPath = fullPath }
  
  local fileData = love.filesystem.newFileData(fullPath)
  
  local f = love.graphics.newFont(fileData, 100)
  local height = f:getHeight()
  -- say height is 60, I want to make sure it is 45 or under, so take 100 * 44 / 60
  local points = math.floor(100 * MAX_FONT_HEIGHT / height)
  f:release() -- free reference and load appropriate height
  
  -- default size to fit nicely in selection box with max height of 50
  f = love.graphics.newFont(fullPath, points)
  
  obj.font = f
  obj.fullPath = fullPath
  obj.rasterizer = rasterizer
  obj.fileData = fileData
  obj.height = f:getHeight()
  obj.pointsPerPixel = 100 / height
  obj.offset = math.floor((LINE_HEIGHT - obj.height) / 2) -- offset from top in box to center veritcally
  obj.points = points
  obj.name = fileName:gsub('%.[^%.]*$','')
  obj.nameWidth = f:getWidth(obj.name)
  table.insert(Fonts.list, obj)
  Fonts.byName[obj.name] = obj
  Fonts.maxWidth = math.max(obj.nameWidth, Fonts.maxWidth)
  
  -- print("Element "..tostring(#Fonts.list).." name:"..tostring(obj.name)..", maxWidth now "..tostring(Fonts.maxWidth)..', Fonts is: '..tostring(Fonts))
end

return Fonts