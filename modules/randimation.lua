---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

---Contains all registered randimations
---@type SquAPI.Randimation[]
squapi.randimations = {}
squapi.randimation = {}
squapi.randimation.__index = squapi.randimation

---RANDOM ANIMATION OBJECT - this will randomly play a given animation with a modifiable chance. (good for blinking)
---@param animation Animation The animation to play.
---@param chanceRange? number Defaults to `200`, an optional paramater that sets the range. 0 means every tick, larger values mean lower chances of playing every tick.
---@param stopOnSleep? boolean Defaults to `false`, if this is for blinking set this to true so that it doesn't blink while sleeping.
---@return SquAPI.Randimation
function squapi.randimation:new(animation, chanceRange, stopOnSleep)
  ---@class SquAPI.Randimation
  local self = setmetatable({}, squapi.randimation)

  -- INIT -------------------------------------------------------------------------
  self.stopOnSleep = stopOnSleep
  self.animation = animation
  self.chanceRange = chanceRange or 200


  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  ---Toggle this randimation on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disable this randimation
  function self:disable()
    self.enabled = false
  end

  ---Enable this randimation
  function self:enable()
    self.enabled = true
  end

  ---Sets if this randimation is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run tick function on randimation
  function events.tick()
    if self.enabled and (not self.stopOnSleep or player:getPose() ~= "SLEEPING") and math.random(0, self.chanceRange) == 0 and self.animation:isStopped() then
      self.animation:play()
    end
  end

  table.insert(squapi.randimations, self)
  return self
end

return squapi.randimation, squapi.randimations