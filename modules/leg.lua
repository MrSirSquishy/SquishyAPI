---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

---Contains all registered legs
---@type SquAPI.Leg[]
squapi.legs = {}
squapi.leg = {}
squapi.leg.__index = squapi.leg

---LEG MOVEMENT - Will make an element mimic the rotation of a vanilla leg, but allows you to control the strength. Good for different length legs or legs under dresses.
---@param element ModelPart The element you want to apply the movement to.
---@param strength? number Defaults to `1`, how much it rotates.
---@param isRight? boolean Defaults to `false`, if this is the right leg or not.
---@param keepPosition? boolean Defaults to `true`, if you want the element to keep it's position as well.
---@return SquAPI.Leg
function squapi.leg:new(element, strength, isRight, keepPosition)
  ---@class SquAPI.Leg
  local self = squassets.vanillaElement:new(element, strength, keepPosition)

  -- INIT -------------------------------------------------------------------------
  if isRight == nil then isRight = false end
  self.isRight = isRight

  -- CONTROL -------------------------------------------------------------------------

  -- UPDATES -------------------------------------------------------------------------

  ---Returns the vanilla leg rotation and position vectors
  ---@return Vector3 #Vanilla leg rotation
  ---@return Vector3 #Vanilla leg position
  function self:getVanilla()
    if self.isRight then
      self.rot = vanilla_model.RIGHT_LEG:getOriginRot()
      self.pos = vanilla_model.RIGHT_LEG:getOriginPos()
    else
      self.rot = vanilla_model.LEFT_LEG:getOriginRot()
      self.pos = vanilla_model.LEFT_LEG:getOriginPos()
    end
    return self.rot, self.pos
  end

  table.insert(squapi.legs, self)
  return self
end

return squapi.leg, squapi.legs