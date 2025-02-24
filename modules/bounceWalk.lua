---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

---Contains all registered bounce walks
---@type SquAPI.BounceWalk[]
squapi.bounceWalks = {}
squapi.bounceWalk = {}
squapi.bounceWalk.__index = squapi.bounceWalk

---BOUNCE WALK - this will make your character curtly bounce/hop with each step (the strength of this bounce can be controlled).
---@param model ModelPart The path to your model element.
---@param bounceMultiplier? number Defaults to `1`, this multiples how much the bounce occurs.
---@return SquAPI.BounceWalk
function squapi.bounceWalk:new(model, bounceMultiplier)
  ---@class SquAPI.BounceWalk
  local self = setmetatable({}, squapi.bounceWalk)
  -- INIT -------------------------------------------------------------------------
  assert(model, "Your model path is incorrect for bounceWalk")
  self.bounceMultiplier = bounceMultiplier or 1
  self.target = 0

  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  ---Toggle this bounce walk on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disable this bounce walk
  function self:disable()
    self.enabled = false
  end

  ---Enable this bounce walk
  function self:enable()
    self.enabled = true
  end

  ---Sets if this bounce walk is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run render function on bounce walk
  function self:render(dt, _)
    local pose = player:getPose()
    if self.enabled and (pose == "STANDING" or pose == "CROUCHING") then
      local leftlegrot = vanilla_model.LEFT_LEG:getOriginRot()[1]
      local bounce = self.bounceMultiplier
      if pose == "CROUCHING" then
        bounce = bounce / 2
      end
      self.target = math.abs(leftlegrot) / 40 * bounce
    else
      self.target = 0
    end
    model:setPos(0, math.lerp(model:getPos()[2], self.target, dt), 0)
  end

  table.insert(squapi.bounceWalks, self)
  return self
end

return squapi.bounceWalk, squapi.bounceWalks