---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

---Contains all registered eyes
---@type SquAPI.Eye[]
squapi.eyes = {}
squapi.eye = {}
squapi.eye.__index = squapi.eye

---MOVING EYES - Moves an eye based on the head rotation to look toward where you look; should work with any general eye type.<br><br>Note: you call this function for each eye, so if you have two eyes you will call this function twice (one for each eye).
---@param element ModelPart The eye element that is going to be moved, each eye is seperate.
---@param leftDistance? number Defaults to `0.25`, the distance from the eye to it's leftmost posistion.
---@param rightDistance? number Defaults to `1.25`, the distance from the eye to it's rightmost posistion.
---@param upDistance? number Defaults to `0.5`, the distance from the eye to it's upmost posistion.
---@param downDistance? number Defaults to `0.5`, the distance from the eye to it's downmost posistion.
---@param switchValues? boolean Defaults to `false`, this will switch from side to side movement to front back movement. this is good if the eyes are on the *side* of the head rather than the *front*.
---@return SquAPI.Eye
function squapi.eye:new(element, leftDistance, rightDistance, upDistance, downDistance, switchValues)
  ---@class SquAPI.Eye
  local self = setmetatable({}, squapi.eye)

  -- INIT -------------------------------------------------------------------------
  assert(element,
    "§4Your eye model path is incorrect.§c")
  self.element = element
  self.switchValues = switchValues or false
  self.left = leftDistance or .25
  self.right = rightDistance or 1.25
  self.up = upDistance or 0.5
  self.down = downDistance or 0.5

  self.x = 0
  self.y = 0
  self.eyeScale = 1

  -- CONTROL -------------------------------------------------------------------------

  ---For funzies if you want to change the scale of the eyes you can use self. (lerps to scale)
  ---@param scale number Scale multiplier
  function self:setEyeScale(scale)
    self.eyeScale = scale
  end

  self.enabled = true
  ---Toggles this eye on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disables this eye
  function self:disable()
    self.enabled = false
  end

  ---Enables this eye
  function self:enable()
    self.enabled = true
  end

  ---Sets if this eye is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  ---Resets this eye's position to its initial posistion
  function self:zero()
    self.x, self.y = 0, 0
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run tick function on eye
  function self:tick()
    if self.enabled then
      local headrot = squassets.getHeadRot()
      headrot[2] = math.max(math.min(50, headrot[2]), -50)

      --parabolic curve so that you can control the middle position of the eyes.
      self.x = -squassets.parabolagraph(-50, -self.left, 0, 0, 50, self.right, headrot[2])
      self.y = squassets.parabolagraph(-90, -self.down, 0, 0, 90, self.up, headrot[1])

      --prevents any eye shenanigans
      self.x = math.max(math.min(self.left, self.x), -self.right)
      self.y = math.max(math.min(self.up, self.y), -self.down)
    end
  end

  ---Run render function on eye
  ---@param dt number Tick delta
  function self:render(dt, _)
    local c = self.element:getPos()
    if self.switchValues then
      self.element:setPos(0, math.lerp(c[2], self.y, dt), math.lerp(c[3], -self.x, dt))
    else
      self.element:setPos(math.lerp(c[1], self.x, dt), math.lerp(c[2], self.y, dt), 0)
    end
    local scale = math.lerp(self.element:getOffsetScale()[1], self.eyeScale, dt)
    self.element:setOffsetScale(scale, scale, scale)
  end

  table.insert(squapi.eyes, self)
  return self
end

return squapi.eye, squapi.eyes