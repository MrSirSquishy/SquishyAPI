---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

---Contains all registered hover points
---@type SquAPI.HoverPoint[]
squapi.hoverPoints = {}
squapi.hoverPoint = {}
squapi.hoverPoint.__index = squapi.hoverPoint

---HOVER POINT ITEM - this will cause this element to naturally float to it’s normal position rather than being locked with the players movement. Great for floating companions.
---@param element ModelPart The element you are moving.
---@param elementOffset? Vector3 Defaults to `vec(0,0,0)`, the position of the hover point relative to you.
---@param springStrength? number Defaults to `0.2`, how strongly the object is pulled to it's original spot.
---@param mass? number Defaults to `5`, how heavy the object is (heavier accelerate/deccelerate slower).
---@param resistance? number Defaults to `1`, how much the elements speed decays (like air resistance).
---@param rotationSpeed? number Defaults to `0.05`, how fast the element should rotate to it's normal rotation.
---@param rotateWithPlayer? boolean Defaults to `true`, wheather or not the hoverPoint should rotate with you
---@param doCollisions? boolean Defaults to `false`, whether or not the element should collide with blocks (warning: the system is janky).
---@return SquAPI.HoverPoint
function squapi.hoverPoint:new(element, elementOffset, springStrength, mass, resistance,
                               rotationSpeed, rotateWithPlayer, doCollisions)
  ---@class SquAPI.HoverPoint
  local self = setmetatable({}, squapi.hoverPoint)

  -- INIT -------------------------------------------------------------------------
  self.element = element
  assert(self.element,
    "§4The Hover point's model path is incorrect.§c")
  self.element:setParentType("WORLD")
  elementOffset = elementOffset or vec(0, 0, 0)
  self.elementOffset = elementOffset * 16
  self.springStrength = springStrength or 0.2
  self.mass = mass or 5
  self.resistance = resistance or 1
  self.rotationSpeed = rotationSpeed or 0.05
  self.doCollisions = doCollisions
  self.rotateWithPlayer = rotateWithPlayer
  if self.rotateWithPlayer == nil then self.rotateWithPlayer = true end

  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  ---Toggles this hover point on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disables this hover point
  function self:disable()
    self.enabled = false
  end

  ---Enables this hover point
  function self:enable()
    self.enabled = true
  end

  ---Sets if this hover point is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  ---Resets this hover point's position to its initial position
  function self:reset()
    local yaw
    if self.rotateWithPlayer then
      yaw = math.rad(player:getBodyYaw() + 180)
    else
      yaw = 0
    end
    local sin, cos = math.sin(yaw), math.cos(yaw)
    local offset = vec(
      cos * self.elementOffset.x - sin * self.elementOffset.z,
      self.elementOffset.y,
      sin * self.elementOffset.x + cos * self.elementOffset.z
    )
    self.pos = player:getPos() + offset / 16
    self.element:setPos(self.pos * 16)
    self.element:setOffsetRot(0, -player:getBodyYaw() + 180, 0)
  end

  self.pos = vec(0, 0, 0)
  self.vel = vec(0, 0, 0)

  -- UPDATES -------------------------------------------------------------------------

  self.init = true
  self.delay = 0

  function self:tick()
    if self.enabled then
      local yaw
      if self.rotateWithPlayer then
        yaw = math.rad(player:getBodyYaw() + 180)
      else
        yaw = 0
      end

      local sin, cos = math.sin(yaw), math.cos(yaw)
      local offset = vec(
        cos * self.elementOffset.x - sin * self.elementOffset.z,
        self.elementOffset.y,
        sin * self.elementOffset.x + cos * self.elementOffset.z
      )

      if self.init then
        self.init = false
        self.pos = player:getPos() + offset / 16
        self.element:setPos(self.pos * 16)
        self.element:setOffsetRot(0, -player:getBodyYaw() + 180, 0)
      end

      --adjusts the target based on the players rotation
      local target = player:getPos() + offset / 16
      local pos = self.element:partToWorldMatrix():apply()
      local dif = self.pos - target

      local force = vec(0, 0, 0)

      if self.delay == 0 then
        --behold my very janky collision system
        if self.doCollisions and world.getBlockState(pos):getCollisionShape()[1] then
          local block, hitPos, side = raycast:block(pos - self.vel * 2, pos)
          self.pos = self.pos + (hitPos - pos)
          if side == "east" or side == "west" then
            self.vel.x = -self.vel.x * 0.5
          elseif side == "north" or side == "south" then
            self.vel.z = -self.vel.z * 0.5
          else
            self.vel.y = -self.vel.y * 0.5
          end
          self.delay = 2
        else
          force = force - dif * self.springStrength --spring force
        end
      else
        self.delay = self.delay - 1
      end
      force = force - self.vel * self.resistance --resistive force(based on air resistance)

      self.vel = self.vel + force / self.mass
      self.pos = self.pos + self.vel
    end
  end

  ---Run render function on hover point
  ---@param dt number Tick delta
  function self:render(dt, _)
    self.element:setPos(
      math.lerp(self.element:getPos(), self.pos * 16, dt / 2)
    )
    self.element:setOffsetRot(0,
      math.lerp(self.element:getOffsetRot()[2], 180 - player:getBodyYaw(), dt * self.rotationSpeed),
      0)
  end

  table.insert(squapi.hoverPoints, self)
  return self
end

return squapi.hoverPoint, squapi.hoverPoints