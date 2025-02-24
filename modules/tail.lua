---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

---Contains all registered tails
---@type SquAPI.Tail[]
squapi.tails = {}
squapi.tail = {}
squapi.tail.__index = squapi.tail

---TAIL PHYSICS - this will add physics to your tails when you spin, move, jump, etc. Has the option to have an idle tail movement, and can work with a tail with any number of segments.
---@param tailSegmentList table<ModelPart> The list of each individual tail segment of your tail.
---@param idleXMovement? number Defaults to `15`, how much the tail should sway side to side.
---@param idleYMovement? number Defaults to `5`, how much the tail should sway up and down.
---@param idleXSpeed? number Defaults to `1.2`, how fast the tail should sway side to side.
---@param idleYSpeed? number Defaults to `2`, how fast the tail should sway up and down.
---@param bendStrength? number Defaults to `2`, how strongly the tail moves when you move.
---@param velocityPush? number Defaults to `0`, this will cause the tail to bend when you move forward/backward, good if your tail is bent downward or upward.
---@param initialMovementOffset? number Defaults to `0`, this will offset the tails initial sway, this is good for when you have multiple tails and you want to desync them.
---@param offsetBetweenSegments? number Defaults to `1`, how much each tail segment should be offset from the previous one.
---@param stiffness? number Defaults to `0.005`, how stiff the tail should be.
---@param bounce? number Defaults to `0.9`, how bouncy the tail should be.
---@param flyingOffset? number Defaults to `90`, when flying, riptiding, or swimming, it may look strange to have the tail stick out, so instead it will rotate to this value(so use this to flatten your tail during these movements).
---@param downLimit? number Defaults to `-90`, the lowest each tail segment can rotate.
---@param upLimit? number Defaults to `45`, the highest each tail segment can rotate.
---@return SquAPI.Tail
function squapi.tail:new(tailSegmentList, idleXMovement, idleYMovement, idleXSpeed, idleYSpeed,
                         bendStrength, velocityPush, initialMovementOffset, offsetBetweenSegments,
                         stiffness, bounce, flyingOffset, downLimit, upLimit)
  ---@class SquAPI.Tail
  local self = setmetatable({}, squapi.tail)

  -- INIT -------------------------------------------------------------------------
  --error checker
  self.tailSegmentList = tailSegmentList
  if type(self.tailSegmentList) == "ModelPart" then
    self.tailSegmentList = { self.tailSegmentList }
  end
  assert(type(self.tailSegmentList) == "table",
    "your tailSegmentList table seems to to be incorrect")

  self.berps = {}
  self.targets = {}
  self.stiffness = stiffness or .005
  self.bounce = bounce or .9
  self.downLimit = downLimit or -90
  self.upLimit = upLimit or 45
  if type(self.tailSegmentList[2]) == "number" then --ah I see you stumbled across my custom tail list creator, if you curious ask me. tail must be >= 3 segments. Naming: tail, tailseg, tailseg2, tailseg3..., tailtip
    local range = self.tailSegmentList[2]
    local str = ""
    if self.tailSegmentList[3] then
      str = self.tailSegmentList[3]
    end

    self.tailSegmentList[2] = self.tailSegmentList[1][str .. "tailseg"]
    for i = 2, range - 2 do
      self.tailSegmentList[i + 1] = self.tailSegmentList[i][str .. "tailseg" .. i]
    end
    self.tailSegmentList[range] = self.tailSegmentList[range - 1][str .. "tailtip"]
  end

  for i = 1, #self.tailSegmentList do
    assert(self.tailSegmentList[i]:getType() == "GROUP",
      "§4The tail segment at position " ..
      i ..
      " of the table is not a group. The tail segments need to be groups that are nested inside the previous segment.§c")
    self.berps[i] = { squassets.BERP:new(self.stiffness, self.bounce), squassets.BERP:new(
      self.stiffness, self.bounce, self.downLimit, self.upLimit) }
    self.targets[i] = { 0, 0 }
  end

  self.tailSegmentList = tailSegmentList
  self.idleXMovement = idleXMovement or 15
  self.idleYMovement = idleYMovement or 5
  self.idleXSpeed = idleXSpeed or 1.2
  self.idleYSpeed = idleYSpeed or 2
  self.bendStrength = bendStrength or 2
  self.velocityPush = velocityPush or 0
  self.initialMovementOffset = initialMovementOffset or 0
  self.flyingOffset = flyingOffset or 90
  self.offsetBetweenSegments = offsetBetweenSegments or 1


  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  function self:toggle()
    self.enabled = not self.enabled
  end

  function self:disable()
    self.enabled = false
  end

  function self:enable()
    self.enabled = true
  end

  function self:zero()
    for _, v in pairs(self.tailSegmentList) do
      v:setOffsetRot(0, 0, 0)
    end
  end

  -- UPDATES -------------------------------------------------------------------------

  self.currentBodyRot = 0
  self.oldBodyRot = 0
  self.bodyRotSpeed = 0

  function self:tick()
    if self.enabled then
      self.oldBodyRot = self.currentBodyRot
      self.currentBodyRot = player:getBodyYaw()
      self.bodyRotSpeed = math.max(math.min(self.currentBodyRot - self.oldBodyRot, 20), -20)

      local time = world.getTime()
      local vel = squassets.forwardVel()
      local yvel = squassets.verticalVel()
      local svel = squassets.sideVel()
      local bendStrength = self.bendStrength / (math.abs((yvel * 30)) + vel * 30 + 1)
      local pose = player:getPose()

      for i = 1, #self.tailSegmentList do
        self.targets[i][1] = math.sin((time * self.idleXSpeed) / 10 -
          (i * self.offsetBetweenSegments)) * self.idleXMovement
        self.targets[i][2] = math.sin((time * self.idleYSpeed) / 10 -
          (i * self.offsetBetweenSegments) + self.initialMovementOffset) * self.idleYMovement

        self.targets[i][1] = self.targets[i][1] + self.bodyRotSpeed * self.bendStrength +
            svel * self.bendStrength * 40
        self.targets[i][2] = self.targets[i][2] + yvel * 15 * self.bendStrength -
            vel * self.bendStrength * 15 * self.velocityPush

        if i == 1 then
          if pose == "FALL_FLYING" or pose == "SWIMMING" or player:riptideSpinning() then
            self.targets[i][2] = self.flyingOffset
          end
        end
      end
    end
  end

  ---Run render function on tail
  ---@param dt number Tick delta
  function self:render(dt, _)
    if self.enabled then
      local pose = player:getPose()
      if pose ~= "SLEEPING" then
        for i, tail in ipairs(self.tailSegmentList) do
          tail:setOffsetRot(
            self.berps[i][2]:berp(self.targets[i][2], dt),
            self.berps[i][1]:berp(self.targets[i][1], dt),
            0
          )
        end
      end
    end
  end

  table.insert(squapi.tails, self)
  return self
end

return squapi.tail, squapi.tails