---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

---Contains all registered first person hands
---@type SquAPI.FPHand[]
squapi.FPHands = {}
squapi.FPHand = {}
squapi.FPHand.__index = squapi.FPHand

---CUSTOM FIRST PERSON HAND<br>**!!Make sure the setting for modifying first person hands is enabled in the Figura settings for this to work properly!!**
---@param element ModelPart The actual hand element to change.
---@param x? number Defaults to `0`, the x change.
---@param y? number Defaults to `0`, the y change.
---@param z? number Defaults to `0`, the z change.
---@param scale? number Defaults to `1`, this will multiply the size of the element by this size.
---@param onlyVisibleInFP? boolean Defaults to `false`, this will make the element invisible when not in first person if true.
---@return SquAPI.FPHand
function squapi.FPHand:new(element, x, y, z, scale, onlyVisibleInFP)
  ---@class SquAPI.FPHand
  local self = setmetatable(self, squapi.FPHand)

  -- INIT -------------------------------------------------------------------------
  assert(element, "Your First Person Hand path is incorrect")
  element:setParentType("RightArm")
  self.element = element
  self.x = x or 0
  self.y = y or 0
  self.z = z or 0
  self.scale = scale or 1
  self.onlyVisibleInFP = onlyVisibleInFP

  -- CONTROL -------------------------------------------------------------------------

  ---Set the first person hand's position
  ---@param _x number X position
  ---@param _y number Y position
  ---@param _z number Z position
  function self:updatePos(_x, _y, _z)
    self.x = _x
    self.y = _y
    self.z = _z
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run render function on first person hand
  ---@param context Event.Render.context
  function self:render(_, context)
    if context == "FIRST_PERSON" then
      if self.onlyVisibleInFP then
        self.element:setVisible(true)
      end
      self.element:setPos(self.x, self.y, self.z)
      self.element:setScale(self.scale, self.scale, self.scale)
    else
      if self.onlyVisibleInFP then
        self.element:setVisible(false)
      end
      self.element:setPos(0, 0, 0)
    end
  end

  table.insert(squapi.FPHands, self)
  return self
end

return squapi.FPHand, squapi.FPHands