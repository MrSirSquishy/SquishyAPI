--[[--------------------------------------------------------------------------------------
███████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗██╗   ██╗     █████╗ ██████╗ ██╗
██╔════╝██╔═══██╗██║   ██║██║██╔════╝██║  ██║╚██╗ ██╔╝    ██╔══██╗██╔══██╗██║
███████╗██║   ██║██║   ██║██║███████╗███████║ ╚████╔╝     ███████║██████╔╝██║
╚════██║██║▄▄ ██║██║   ██║██║╚════██║██╔══██║  ╚██╔╝      ██╔══██║██╔═══╝ ██║
███████║╚██████╔╝╚██████╔╝██║███████║██║  ██║   ██║       ██║  ██║██║     ██║
╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝     ╚═╝
--]] --------------------------------------------------------------------------------------ANSI Shadow

-- Author: Squishy
-- Discord tag: @mrsirsquishy

-- Version: 1.0.0
-- Legal: ARR

-- Special Thanks to
-- @jimmyhelp for errors and just generally helping me get things working.

-- IMPORTANT FOR NEW USERS!!! READ THIS!!!

-- Thank you for using SquAPI! Unless you're experienced and wish to actually modify the functionality
-- of this script, I wouldn't recommend snooping around.
-- Don't know exactly what you're doing? This site contains a guide on how to use!(also linked on github):
-- https://mrsirsquishy.notion.site/Squishy-API-Guide-3e72692e93a248b5bd88353c96d8e6c5

-- This SquAPI file does have some mini-documentation on paramaters if you need like a quick reference, but
-- do not modify, and do not copy-paste code from this file unless you are an avid scripter who knows what they are doing.


-- Don't be afraid to ask me for help, just make sure to provide as much info as possible so I or someone can help you faster.






--setup stuff

-- Locates SquAssets, if it exists
-- Written by FOX
---@class SquAPI.*ASSETS*
local squassets
for _, path in ipairs(listFiles("/", true)) do
  if string.find(path, "SquAssets") then squassets = require(path) end
end
assert(squassets,
  "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}


-- SQUAPI CONTROL VARIABLES AND CONFIG ----------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- these variables can be changed to control certain features of squapi.


--when true it will automatically tick and update all the functions, when false it won't do that.<br>
--if false, you can run each objects respective tick/update functions on your own - better control.
squapi.autoFunctionUpdates = true


-- FUNCTIONS --------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------






---Contains all registered tails
---@class SquAPI.Tails
---@field private [number] SquAPI.Tail
squapi.tails = {}
---@class SquAPI.Tail
squapi.tail = {}
squapi.tail.__index = squapi.tail

---TAIL PHYSICS - This will add physics to your tails when you spin, move, jump, etc. Has the option to have an idle tail movement, and can work with a tail with any number of segments.
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
  local _self = setmetatable({}, squapi.tail)

  -- INIT -------------------------------------------------------------------------
  --error checker
  if type(tailSegmentList) == "ModelPart" then
    tailSegmentList = { tailSegmentList }
  end
  assert(type(tailSegmentList) == "table",
    "your tailSegmentList table seems to to be incorrect")

  _self.berps = {}
  _self.targets = {}
  _self.stiffness = stiffness or .005
  _self.bounce = bounce or .9
  _self.downLimit = downLimit or -90
  _self.upLimit = upLimit or 45
  for i = 1, #tailSegmentList do
    assert(tailSegmentList[i]:getType() == "GROUP",
      "§4The tail segment at position " ..
      i ..
      " of the table is not a group. The tail segments need to be groups that are nested inside the previous segment.§c")
    _self.berps[i] = { squassets.BERP:new(_self.stiffness, _self.bounce), squassets.BERP:new(
      _self.stiffness, _self.bounce, _self.downLimit, _self.upLimit) }
    _self.targets[i] = { 0, 0 }
  end

  _self.tailSegmentList = tailSegmentList
  _self.idleXMovement = idleXMovement or 15
  _self.idleYMovement = idleYMovement or 5
  _self.idleXSpeed = idleXSpeed or 1.2
  _self.idleYSpeed = idleYSpeed or 2
  _self.bendStrength = bendStrength or 2
  _self.velocityPush = velocityPush or 0
  _self.initialMovementOffset = initialMovementOffset or 0
  _self.flyingOffset = flyingOffset or 90
  _self.offsetBetweenSegments = offsetBetweenSegments or 1


  -- CONTROL -------------------------------------------------------------------------

  -- UPDATES -------------------------------------------------------------------------

  _self.currentBodyRot = 0
  _self.oldBodyRot = 0
  _self.bodyRotSpeed = 0

  ---Run tick function on tail
  function _self:tick()
    _self.oldBodyRot = _self.currentBodyRot
    _self.currentBodyRot = player:getBodyYaw()
    _self.bodyRotSpeed = math.max(math.min(_self.currentBodyRot - _self.oldBodyRot, 20), -20)

    local time = world.getTime()
    local vel = squassets.forwardVel()
    local yvel = squassets.verticalVel()
    local svel = squassets.sideVel()
    bendStrength = _self.bendStrength / (math.abs((yvel * 30)) + vel * 30 + 1)
    local pose = player:getPose()

    for i = 1, #_self.tailSegmentList do
      _self.targets[i][1] = math.sin((time * _self.idleXSpeed) / 10 - (i)) * _self.idleXMovement
      _self.targets[i][2] = math.sin((time * _self.idleYSpeed) / 10 -
        (i * _self.offsetBetweenSegments) +
        _self.initialMovementOffset) * _self.idleYMovement

      _self.targets[i][1] = _self.targets[i][1] + _self.bodyRotSpeed * _self.bendStrength +
          svel * _self.bendStrength * 40
      _self.targets[i][2] = _self.targets[i][2] + yvel * 15 * _self.bendStrength -
          vel * _self.bendStrength * 15 * _self.velocityPush

      if i == 1 then
        if pose == "FALL_FLYING" or pose == "SWIMMING" or player:riptideSpinning() then
          _self.targets[i][2] = _self.flyingOffset
        end
      end
    end
  end

  ---Run render function on tail
  ---@param dt number Tick delta
  function _self:render(dt, _)
    local pose = player:getPose()
    if pose ~= "SLEEPING" then
      for i, tail in ipairs(_self.tailSegmentList) do
        tail:setOffsetRot(
          _self.berps[i][2]:berp(_self.targets[i][2], dt),
          _self.berps[i][1]:berp(_self.targets[i][1], dt),
          0
        )
      end
    else

    end
  end

  table.insert(squapi.tails, _self)
  return _self
end

---Contains all registered ears
---@class SquAPI.Ears
---@field private [number] SquAPI.Ear
squapi.ears = {}
---@class SquAPI.Ear
squapi.ear = {}
squapi.ear.__index = squapi.ear

---EAR PHYSICS - This adds physics to your ear(s) when you move, and has options for different ear types.
---@param leftEar ModelPart The left ear's model path.
---@param rightEar? ModelPart The right ear's model path, if you don't have a right ear, just leave this blank or set to nil.
---@param rangeMultiplier? number Defaults to `1`, how far the ears should rotate with your head.
---@param horizontalEars? boolean Defaults to `false`, if you have elf-like ears(ears that stick out horizontally), set this to true.
---@param bendStrength? number Defaults to `2`, how much the ears should move when you move.
---@param doEarFlick? boolean Defaults to `true`, whether or not the ears should randomly flick.
---@param earFlickChance? number Defaults to `400`, how often the ears should flick in ticks, timer is random between 0 to n ticks.
---@param earStiffness? number Defaults to `0.1`, how stiff the ears should be.
---@param earBounce? number Defaults to `0.8`, how bouncy the ears should be.
---@return SquAPI.Ear
function squapi.ear:new(leftEar, rightEar, rangeMultiplier, horizontalEars, bendStrength, doEarFlick,
                        earFlickChance, earStiffness, earBounce)
  ---@class SquAPI.Ear
  local _self = setmetatable({}, squapi.ear)

  -- INIT -------------------------------------------------------------------------

  assert(leftEar,
    "§4The first ear's model path is incorrect.§c")
  _self.leftEar = leftEar
  _self.rightEar = rightEar
  _self.horizontalEars = horizontalEars
  _self.rangeMultiplier = rangeMultiplier or 1
  if _self.horizontalEars then self.rangeMultiplier = self.rangeMultiplier / 2 end
  _self.bendStrength = bendStrength or 2
  earStiffness = earStiffness or 0.1
  earBounce = earBounce or 0.8

  if doEarFlick == nil then doEarFlick = true end
  _self.doEarFlick = doEarFlick
  _self.earFlickChance = earFlickChance or 400

  -- CONTROL -------------------------------------------------------------------------

  _self.enabled = true
  ---Toggle this ear on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disable this ear
  function _self:disable()
    _self.enabled = false
  end

  ---Enable this ear
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if this ear is enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  _self.eary = squassets.BERP:new(earStiffness, earBounce)
  _self.earx = squassets.BERP:new(earStiffness, earBounce)
  _self.earz = squassets.BERP:new(earStiffness, earBounce)
  _self.targets = { 0, 0, 0 }
  _self.oldpose = "STANDING"

  ---Run tick function on ear
  function _self:tick()
    if _self.enabled then
      local vel = math.min(math.max(-0.75, squassets.forwardVel()), 0.75)
      local yvel = math.min(math.max(-1.5, squassets.verticalVel()), 1.5) * 5
      local svel = math.min(math.max(-0.5, squassets.sideVel()), 0.5)
      local headrot = squassets.getHeadRot()
      local bend = _self.bendStrength
      if headrot[1] < -22.5 then bend = -bend end

      --gives the ears a short push when crouching/uncrouching
      local pose = player:getPose()
      if pose == "CROUCHING" and _self.oldpose == "STANDING" then
        _self.eary.vel = _self.eary.vel + 5 * _self.bendStrength
      elseif pose == "STANDING" and _self.oldpose == "CROUCHING" then
        _self.eary.vel = _self.eary.vel - 5 * _self.bendStrength
      end
      _self.oldpose = pose

      --main physics
      if _self.horizontalEars then
        local rot = 10 * bend * (yvel + vel * 10) + headrot[1] * _self.rangeMultiplier
        local addrot = headrot[2] * _self.rangeMultiplier
        _self.targets[2] = rot + addrot
        _self.targets[3] = -rot + addrot
      else
        _self.targets[1] = headrot[1] * _self.rangeMultiplier + 2 * bend * (yvel + vel * 15)
        _self.targets[2] = headrot[2] * _self.rangeMultiplier - svel * 100 * _self.bendStrength
        _self.targets[3] = _self.targets[2]
      end

      --ear flicking
      if _self.doEarFlick then
        if math.random(0, _self.earFlickChance) == 1 then
          if math.random(0, 1) == 1 then
            _self.earx.vel = _self.earx.vel + 50
          else
            _self.earz.vel = _self.earz.vel - 50
          end
        end
      end
    else
      leftEar:setOffsetRot(0, 0, 0)
      rightEar:setOffsetRot(0, 0, 0)
    end
  end

  ---Run render function on ear
  ---@param dt number Tick delta
  function _self:render(dt, _)
    if _self.enabled then
      _self.eary:berp(_self.targets[1], dt)
      _self.earx:berp(_self.targets[2], dt)
      _self.earz:berp(_self.targets[3], dt)

      local rot3 = _self.earx.pos / 4
      local rot3b = _self.earz.pos / 4

      if _self.horizontalEars then
        local y = _self.eary.pos / 4
        _self.leftEar:setOffsetRot(y, _self.earx.pos / 3, rot3)
        if _self.rightEar then
          _self.rightEar:setOffsetRot(y, _self.earz.pos / 3, rot3b)
        end
      else
        _self.leftEar:setOffsetRot(_self.eary.pos, rot3, rot3)
        if _self.rightEar then
          _self.rightEar:setOffsetRot(_self.eary.pos, rot3b, rot3b)
        end
      end
    end
  end

  table.insert(squapi.ears, _self)
  return _self
end

---CROUCH ANIMATION - This allows you to set an animation for your crouch (this can either be a static pose for crouching, or an animation to transition to crouching)<br><br>It also allows you to optionally set an uncrouch animation, and includes the same features mentioned for crawling if you need as well.
---@param crouch Animation The animation to play when you crouch. Make sure this animation is on "hold on last frame" and override.
---@param uncrouch? Animation The animation to play when you uncrouch. make sure to set to "play once" and set to override. If it's just a pose with no actual animation, than you should leave this blank or set to nil.
---@param crawl? Animation Same as crouch but for crawling.
---@param uncrawl? Animation Same as uncrouch but for crawling.
---@class SquAPI.Crouch
function squapi.crouch(crouch, uncrouch, crawl, uncrawl)
  local oldstate = "STANDING"
  function events.render()
    local pose = player:getPose()
    if pose == "SWIMMING" and not player:isInWater() then pose = "CRAWLING" end

    if pose == "CROUCHING" then
      if uncrouch ~= nil then
        uncrouch:stop()
      end
      crouch:play()
    elseif oldstate == "CROUCHING" then
      crouch:stop()
      if uncrouch ~= nil then
        uncrouch:play()
      end
    elseif crawl ~= nil then
      if pose == "CRAWLING" then
        if uncrawl ~= nil then
          uncrawl:stop()
        end
        crawl:play()
      elseif oldstate == "CRAWLING" then
        crawl:stop()
        if uncrawl ~= nil then
          uncrawl:play()
        end
      end
    end

    oldstate = pose
  end
end

---Contains all registered bewbs
---@class SquAPI.Bewbs
---@field private [number] SquAPI.Bewb
squapi.bewbs = {}
---@class SquAPI.Bewb
squapi.bewb = {}
squapi.bewb.__index = squapi.bewb

---BEWB PHYSICS - This can add bewb physics to your avatar, which for some reason is also versatile for non-tiddy related activities.
---@param element ModelPart The bewb element that you want to affect (models.[modelname].path).
---@param bendability? number Defaults to `2`, how much the bewb should move when you move.
---@param stiff? number Defaults to `0.05`, how stiff the bewb should be.
---@param bounce? number Defaults to `0.9`, how bouncy the bewb should be.
---@param doIdle? boolean Defaults to `true`, whether or not the bewb should have an idle sway (like breathing).
---@param idleStrength? number Defaults to `4`, how much the bewb should sway when idle.
---@param idleSpeed? number Defaults to `1`, how fast the bewb should sway when idle.
---@param downLimit? number Defaults to `-10`, the lowest the bewb can rotate.
---@param upLimit? number Defaults to `25`, the highest the bewb can rotate.
---@return SquAPI.Bewb
function squapi.bewb:new(element, bendability, stiff, bounce, doIdle, idleStrength, idleSpeed,
                         downLimit, upLimit)
  ---@class SquAPI.Bewb
  local _self = setmetatable({}, squapi.bewb)

  -- INIT -------------------------------------------------------------------------
  assert(element, "§4Your model path for bewb is incorrect.§c")
  _self.element = element
  if doIdle == nil then doIdle = true end
  _self.doIdle = doIdle
  _self.bendability = bendability or 2
  _self.bewby = squassets.BERP:new(stiff or 0.05, bounce or 0.9, downLimit or -10, upLimit or 25)
  _self.idleStrength = idleStrength or 4
  _self.idleSpeed = idleSpeed or 1
  _self.target = 0

  -- CONTROL -------------------------------------------------------------------------

  _self.enabled = true
  ---Toggle these bewbs on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disable these bewbs
  function _self:disable()
    _self.enabled = false
  end

  ---Enable these bewbs
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if these bewbs are enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  -- UPDATE -------------------------------------------------------------------------

  _self.oldpose = "STANDING"
  ---Run tick function on bewbs
  function _self:tick()
    if _self.enabled then
      local vel = squassets.forwardVel()
      local yvel = squassets.verticalVel()
      local worldtime = world.getTime()

      if _self.doIdle then
        _self.target = math.sin(worldtime / 8 * _self.idleSpeed) * _self.idleStrength
      end

      --physics when crouching/uncrouching
      local pose = player:getPose()
      if pose == "CROUCHING" and _self.oldpose == "STANDING" then
        _self.bewby.vel = _self.bewby.vel + _self.bendability
      elseif pose == "STANDING" and _self.oldpose == "CROUCHING" then
        _self.bewby.vel = _self.bewby.vel - _self.bendability
      end
      _self.oldpose = pose

      --physics when moving
      _self.bewby.vel = _self.bewby.vel - yvel * _self.bendability
      _self.bewby.vel = _self.bewby.vel - vel * _self.bendability
    else
      _self.target = 0
    end
  end

  ---Run render function on bewbs
  ---@param dt number Tick delta
  function _self:render(dt, _)
    _self.element:setOffsetRot(_self.bewby:berp(_self.target, dt), 0, 0)
  end

  table.insert(squapi.bewbs, _self)
  return _self
end

---Contains all registered randimations
---@class SquAPI.Randimations
---@field private [number] SquAPI.Randimation
squapi.randimations = {}
---@class SquAPI.Randimation
squapi.randimation = {}
squapi.randimation.__index = squapi.randimation

---RANDOM ANIMATION OBJECT - This will randomly play a given animation with a modifiable chance. (good for blinking)
---@param animation Animation The animation to play.
---@param chanceRange? number Defaults to `200`, an optional paramater that sets the range. 0 means every tick, larger values mean lower chances of playing every tick.
---@param isBlink? boolean Defaults to `false`, if this is for blinking set this to true so that it doesn't blink while sleeping.
---@return SquAPI.Randimation
function squapi.randimation:new(animation, chanceRange, isBlink)
  ---@class SquAPI.Randimation
  local _self = setmetatable({}, squapi.randimation)

  -- INIT -------------------------------------------------------------------------
  _self.isBlink = isBlink
  _self.animation = animation
  _self.chanceRange = chanceRange or 200


  -- CONTROL -------------------------------------------------------------------------

  _self.enabled = true
  ---Toggle this randimation on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disable this randimation
  function _self:disable()
    _self.enabled = false
  end

  ---Enable this randimation
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if this randimation is enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run tick function on randimation
  function events.tick()
    if _self.enabled and (not _self.isBlink or player:getPose() ~= "SLEEPING") and math.random(0, _self.chanceRange) == 0 and _self.animation:isStopped() then
      _self.animation:play()
    end
  end

  table.insert(squapi.randimations, _self)
  return _self
end

---Contains all registered eyes
---@class SquAPI.Eyes
---@field private [number] SquAPI.Eye
squapi.eyes = {}
---@class SquAPI.Eye
squapi.eye = {}
squapi.eye.__index = squapi.eye

---MOVING EYES - Moves an eye based on the head rotation to look toward where you look; should work with any general eye type.<br><br>Note: you call this function for each eye, so if you have two eyes you will call this function twice (one for each eye).
---@param element ModelPart The eye element that is going to be moved, each eye is seperate.
---@param leftDistance? number Defaults to `0.25`, the distance from the eye to it's leftmost posistion.
---@param rightDistance? number Defaults to `1.25`, the distance from the eye to it's rightmost posistion.
---@param upDistance? number Defaults to `0.5`, the distance from the eye to it's upmost posistion.
---@param downDistance? number Defaults to `0.5`, the distance from the eye to it's downmost posistion.
---@param switchValues? boolean Defaults to `false`, this will switch from side to side movement to front back movement. This is good if the eyes are on the *side* of the head rather than the *front*.
---@return SquAPI.Eye
function squapi.eye:new(element, leftDistance, rightDistance, upDistance, downDistance, switchValues)
  ---@class SquAPI.Eye
  local _self = setmetatable({}, squapi.eye)

  -- INIT -------------------------------------------------------------------------
  assert(element,
    "§4Your eye model path is incorrect.§c")
  _self.switchValues = switchValues or false
  _self.left = leftDistance or .25
  _self.right = rightDistance or 1.25
  _self.up = upDistance or 0.5
  _self.down = downDistance or 0.5

  _self.x = 0
  _self.y = 0
  _self.eyeScale = 1

  -- CONTROL -------------------------------------------------------------------------

  ---For funzies if you want to change the scale of the eyes you can use this. (lerps to scale)
  ---@param scale number Scale multiplier
  function _self:setEyeScale(scale)
    _self.eyeScale = scale
  end

  _self.enabled = true
  ---Toggles this eye on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disables this eye
  function _self:disable()
    _self.enabled = false
  end

  ---Enables this eye
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if this eye is enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  ---Resets this eye's position to its initial posistion
  function _self:zero()
    _self.x, _self.y = 0, 0
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run tick function on eye
  function _self:tick()
    if _self.enabled then
      local headrot = squassets.getHeadRot()
      headrot[2] = math.max(math.min(50, headrot[2]), -50)

      --parabolic curve so that you can control the middle position of the eyes.
      _self.x = -squassets.parabolagraph(-50, -_self.left, 0, 0, 50, _self.right, headrot[2])
      _self.y = squassets.parabolagraph(-90, -_self.down, 0, 0, 90, _self.up, headrot[1])

      --prevents any eye shenanigans
      _self.x = math.max(math.min(_self.left, _self.x), -_self.right)
      _self.y = math.max(math.min(_self.up, _self.y), -_self.down)
    end
  end

  ---Run render function on eye
  ---@param dt number Tick delta
  function _self:render(dt, _)
    local c = element:getPos()
    if _self.switchValues then
      element:setPos(0, math.lerp(c[2], _self.y, dt), math.lerp(c[3], -_self.x, dt))
    else
      element:setPos(math.lerp(c[1], _self.x, dt), math.lerp(c[2], _self.y, dt), 0)
    end
    local scale = math.lerp(element:getOffsetScale()[1], _self.eyeScale, dt)
    element:setOffsetScale(scale, scale, scale)
  end

  table.insert(squapi.eyes, _self)
  return _self
end

---Contains all registered hover points
---@class SquAPI.HoverPoints
---@field private [number] SquAPI.HoverPoint
squapi.hoverPoints = {}
---@class SquAPI.HoverPoint
squapi.hoverPoint = {}
squapi.hoverPoint.__index = squapi.hoverPoint

---HOVER POINT ITEM - This will cause this element to naturally float to it’s normal position rather than being locked with the players movement. Great for floating companions.
---@param element ModelPart The element you are moving.
---@param springStrength? number Defaults to `0.2`, how strongly the object is pulled to it's original spot.
---@param mass? number Defaults to `5`, how heavy the object is (heavier accelerate/deccelerate slower).
---@param resistance? number Defaults to `1`, how much the elements speed decays (like air resistance).
---@param rotationSpeed? number Defaults to `0.05`, how fast the element should rotate to it's normal rotation.
---@param doCollisions? boolean Defaults to `false`, whether or not the element should collide with blocks (warning: the system is janky).
---@return SquAPI.HoverPoint
function squapi.hoverPoint:new(element, springStrength, mass, resistance, rotationSpeed, doCollisions)
  ---@class SquAPI.HoverPoint
  local _self = setmetatable({}, squapi.hoverPoint)

  -- INIT -------------------------------------------------------------------------
  _self.element = element
  assert(_self.element,
    "§4The Hover point's model path is incorrect.§c")
  _self.element:setParentType("WORLD")


  _self.springStrength = springStrength or 0.2
  _self.mass = mass or 5
  _self.resistance = resistance or 1
  _self.rotationSpeed = rotationSpeed or 0.05
  _self.doCollisions = doCollisions

  -- CONTROL -------------------------------------------------------------------------

  _self.enabled = true
  ---Toggles this hover point on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disables this hover point
  function _self:disable()
    _self.enabled = false
  end

  ---Enables this hover point
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if this hover point is enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  ---Resets this hover point's position to its initial position
  function _self:reset()
    local yaw = math.rad(player:getBodyYaw())
    local sin, cos = math.sin(yaw), math.cos(yaw)
    local offset = vec(
      cos * _self.elementOffset.x - sin * _self.elementOffset.z,
      _self.elementOffset.y,
      sin * _self.elementOffset.x + cos * _self.elementOffset.z
    )
    _self.element:setPos((player:getPos() - _self.elementOffset + offset) * 16)
  end

  _self.pos = vec(0, 0, 0)
  _self.vel = vec(0, 0, 0)

  -- UPDATES -------------------------------------------------------------------------

  _self.elementOffset = vec(0, 0, 0)
  _self.init = true
  _self.delay = 0

  ---Run tick function on hover point
  function _self:tick()
    if _self.enabled then
      if _self.init then
        _self.init = false
        _self.pos = player:getPos()
        _self.elementOffset = _self.element:partToWorldMatrix():apply()
        _self.element:setPos(_self.pos * 16)
        _self.element:setOffsetRot(0, -player:getBodyYaw(), 0)
      end

      local yaw = math.rad(player:getBodyYaw())
      local sin, cos = math.sin(yaw), math.cos(yaw)

      --adjusts the target based on the players rotation
      local offset = vec(
        cos * _self.elementOffset.x - sin * _self.elementOffset.z,
        _self.elementOffset.y,
        sin * _self.elementOffset.x + cos * _self.elementOffset.z
      )

      local target = (player:getPos() - _self.elementOffset) + offset
      local pos = _self.element:partToWorldMatrix():apply()
      local dif = _self.pos - target

      local force = vec(0, 0, 0)

      if _self.delay == 0 then
        --behold my very janky collision system
        if _self.doCollisions and world.getBlockState(pos):getCollisionShape()[1] then
          local _, hitPos, side = raycast:block(pos - _self.vel * 2, pos)
          _self.pos = _self.pos + (hitPos - pos)
          if side == "east" or side == "west" then
            _self.vel.x = -_self.vel.x * 0.5
          elseif side == "north" or side == "south" then
            _self.vel.z = -_self.vel.z * 0.5
          else
            _self.vel.y = -_self.vel.y * 0.5
          end
          _self.delay = 2
        else
          force = force - dif * _self.springStrength --spring force
        end
      else
        _self.delay = _self.delay - 1
      end
      force = force - _self.vel * _self.resistance --resistive force(based on air resistance)

      _self.vel = _self.vel + force / _self.mass
      _self.pos = _self.pos + _self.vel
    end
  end

  ---Run render function on hover point
  ---@param dt number Tick delta
  function _self:render(dt, _)
    _self.element:setPos(
      math.lerp(_self.element:getPos(), _self.pos * 16, dt / 2)
    )
    _self.element:setOffsetRot(0,
      math.lerp(_self.element:getOffsetRot()[2], -player:getBodyYaw(), dt * _self.rotationSpeed), 0)
  end

  table.insert(squapi.hoverPoints, _self)
  return _self
end

---Contains all registered legs
---@class SquAPI.Legs
---@field private [number] SquAPI.Leg
squapi.legs = {}
---@class SquAPI.Leg
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
  local _self = squassets.vanillaElement:new(element, strength, keepPosition)

  -- INIT -------------------------------------------------------------------------
  if isRight == nil then isRight = false end
  _self.isRight = isRight

  -- CONTROL -------------------------------------------------------------------------

  -- UPDATES -------------------------------------------------------------------------

  ---Returns the vanilla leg rotation and position vectors
  ---@return Vector3 #Vanilla leg rotation
  ---@return Vector3 #Vanilla leg position
  function _self:getVanilla()
    if _self.isRight then
      _self.rot = vanilla_model.RIGHT_LEG:getOriginRot()
      _self.pos = vanilla_model.RIGHT_LEG:getOriginPos()
    else
      _self.rot = vanilla_model.LEFT_LEG:getOriginRot()
      _self.pos = vanilla_model.LEFT_LEG:getOriginPos()
    end
    return _self.rot, _self.pos
  end

  table.insert(squapi.legs, _self)
  return _self
end

---Contains all registered arms
---@class SquAPI.Arms
---@field private [number] SquAPI.Arm
squapi.arms = {}
---@class SquAPI.Arm
squapi.arm = {}
squapi.arm.__index = squapi.arm

---ARM MOVEMENT - Will make an element mimic the rotation of a vanilla arm, but allows you to control the strength. Good for different length arms.
---@param element ModelPart The element you want to apply the movement to.
---@param strength? number Defaults to `1`, how much it rotates.
---@param isRight? boolean Defaults to `false`, if this is the right arm or not.
---@param keepPosition? boolean Defaults to `true`, if you want the element to keep it's position as well.
---@return SquAPI.Arm
function squapi.arm:new(element, strength, isRight, keepPosition)
  ---@class SquAPI.Arm
  local _self = squassets.vanillaElement:new(element, strength, keepPosition)

  -- INIT -------------------------------------------------------------------------
  if isRight == nil then isRight = false end
  _self.isRight = isRight

  -- CONTROL -------------------------------------------------------------------------

  --inherits functions from squassets.vanillaElement

  -- UPDATES -------------------------------------------------------------------------

  ---Returns the vanilla arm rotation and position vectors
  ---@return Vector3 #Vanilla arm rotation
  ---@return Vector3 #Vanilla arm position
  function _self:getVanilla()
    if _self.isRight then
      _self.rot = vanilla_model.RIGHT_ARM:getOriginRot()
    else
      _self.rot = vanilla_model.LEFT_ARM:getOriginRot()
    end
    _self.pos = -vanilla_model.LEFT_ARM:getOriginPos()
    return _self.rot, _self.pos
  end

  table.insert(squapi.arms, _self)
  return _self
end

---Contains all registered smooth heads
---@class SquAPI.SmoothHeads
---@field private [number] SquAPI.SmoothHead
squapi.smoothHeads = {}
---@class SquAPI.SmoothHead
squapi.smoothHead = {}
squapi.smoothHead.__index = squapi.smoothHead

---SMOOTH HEAD - Mimics a vanilla player head, but smoother and with some extra life. Can also do smooth Torsos and Smooth Necks!
---@param element ModelPart|table<ModelPart> The head element that you wish to effect. If you want a smooth neck or torso, instead of a single element, input a table of head elements(imagine it like {element1, element2, etc.}). This will apply the head rotations to each of these.
---@param strength? number|table<number> Defaults to `1`, the target rotation is multiplied by this factor. If you want a smooth neck or torso, instead of an single number, you can put in a table(imagine it like {strength1, strength2, etc.}). This will apply each strength to each respective element.(make sure it is the same length as your element table)
---@param tilt? number Defaults to `0.1`, for context the smooth head applies a slight tilt to the head as it's rotated toward the side, this controls the strength of that tilt.
---@param speed? number Defaults to `1`, how fast the head will rotate toward the target rotation.
---@param keepOriginalHeadPos? boolean|number Defaults to `true`, when true the heads position will follow the vanilla head position. For example when crouching the head will shift down to follow. If set to a number, changes which modelpart gets moved when doing actions such as crouching. This should normally be set to the neck modelpart.
---@param fixPortrait? boolean Defaults to `true`, sets whether or not the portrait should be applied if a group named "head" is found in the elements list
function squapi.smoothHead:new(element, strength, tilt, speed, keepOriginalHeadPos, fixPortrait)
  ---@class SquAPI.SmoothHead
  local _self = setmetatable({}, squapi.smoothHead)

  -- INIT -------------------------------------------------------------------------
  if type(element) == "ModelPart" then
    assert(element, "§4Your model path for smoothHead is incorrect.§c")
    element = { element }
  end
  assert(type(element) == "table", "§4your element table seems to to be incorrect.§c")

  for i = 1, #element do
    assert(element[i]:getType() == "GROUP",
      "§4The head element at position " ..
      i ..
      " of the table is not a group. The head elements need to be groups that are nested inside one another to function properly.§c")
    assert(element[i], "§4The head segment at position " .. i .. " is incorrect.§c")
    element[i]:setParentType("NONE")
  end
  _self.element = element

  _self.strength = strength or 1
  if type(_self.strength) == "number" then
    local strengthDiv = _self.strength / #element
    _self.strength = {}
    for i = 1, #element do
      _self.strength[i] = strengthDiv
    end
  end

  _self.tilt = tilt or 0.1
  if keepOriginalHeadPos == nil then keepOriginalHeadPos = true end
  _self.keepOriginalHeadPos = keepOriginalHeadPos
  _self.headRot = vec(0, 0, 0)
  _self.offset = vec(0, 0, 0)
  _self.speed = (speed or 1) / 2

  if fixPortrait == nil then fixPortrait = true end
  if fixPortrait then
    if type(element) == "table" then
      for _, part in ipairs(element) do
        if squassets.caseInsensitiveFind(part, "head") then
          part:copy("_squapi-portrait"):moveTo(models):setParentType("Portrait")
              :setPos(-part:getPivot())
          break
        end
      end
    elseif type(element) == "ModelPart" and element:getType() == "GROUP" then
      if squassets.caseInsensitiveFind(element, "head") then
        element:copy("_squapi-portrait"):moveTo(models):setParentType("Portrait")
            :setPos(-element:getPivot())
      end
    end
  end

  -- CONTROL -------------------------------------------------------------------------


  ---Applies an offset to the heads rotation to more easily modify it. Applies as a vector.(for multisegments it will modify the target rotation)
  ---@param xRot number X rotation
  ---@param yRot number Y rotation
  ---@param zRot number Z rotation
  function _self:setOffset(xRot, yRot, zRot)
    _self.offset = vec(xRot, yRot, zRot)
  end

  _self.enabled = true
  ---Toggles this smooth head on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disables this smooth head
  function _self:disable()
    _self.enabled = false
  end

  ---Enables this smooth head
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if this smooth head is enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  ---Resets this smooth head's position and rotation to their initial values
  function _self:zero()
    for _, v in ipairs(_self.element) do
      v:setPos(0, 0, 0)
      v:setOffsetRot(0, 0, 0)
      _self.headRot = vec(0, 0, 0)
    end
  end

  -- UPDATE -------------------------------------------------------------------------

  ---Run tick function on smooth head
  function _self:tick()
    if _self.enabled then
      local vanillaHeadRot = squassets.getHeadRot()

      _self.headRot[1] = _self.headRot[1] + (vanillaHeadRot[1] - _self.headRot[1]) * _self.speed
      _self.headRot[2] = _self.headRot[2] + (vanillaHeadRot[2] - _self.headRot[2]) * _self.speed
      _self.headRot[3] = _self.headRot[2] * _self.tilt
    end
  end

  ---Run render function on smooth head
  ---@param dt number Tick delta
  ---@param context Event.Render.context
  function _self:render(dt, context)
    if _self.enabled then
      dt = dt / 5
      for i in ipairs(_self.element) do
        local c = _self.element[i]:getOffsetRot()
        local target = (_self.headRot * _self.strength[i]) - _self.offset / #_self.element
        _self.element[i]:setOffsetRot(math.lerp(c[1], target[1], dt), math.lerp(c[2], target[2], dt),
          math.lerp(c[3], target[3], dt))

        -- Better Combat SquAPI Compatibility created by @jimmyhelp and @foxy2526 on Discord
        if renderer:isFirstPerson() and context == "RENDER" then
          _self.element[i]:setVisible(false)
        else
          _self.element[i]:setVisible(true)
        end
      end

      if _self.keepOriginalHeadPos then
        _self.element
            [type(_self.keepOriginalHeadPos) == "number" and _self.keepOriginalHeadPos or #_self.element]
            :setPos(-vanilla_model.HEAD:getOriginPos())
      end
    end
  end

  table.insert(squapi.smoothHeads, _self)
  return _self
end

---Contains all registered bounce walks
---@class SquAPI.BounceWalks
---@field private [number] SquAPI.BounceWalk
squapi.bounceWalks = {}
---@class SquAPI.BounceWalk
squapi.bounceWalk = {}
squapi.bounceWalk.__index = squapi.bounceWalk

---BOUNCE WALK - This will make your character curtly bounce/hop with each step (the strength of this bounce can be controlled).
---@param model ModelPart The path to your model element.
---@param bounceMultiplier? number Defaults to `1`, this multiples how much the bounce occurs.
---@return SquAPI.BounceWalk
function squapi.bounceWalk:new(model, bounceMultiplier)
  ---@class SquAPI.BounceWalk
  local _self = setmetatable({}, squapi.bounceWalk)
  -- INIT -------------------------------------------------------------------------
  assert(model, "Your model path is incorrect for bounceWalk")
  _self.bounceMultiplier = bounceMultiplier or 1
  _self.target = 0

  -- CONTROL -------------------------------------------------------------------------

  _self.enabled = true
  ---Toggle this bounce walk on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disable this bounce walk
  function _self:disable()
    _self.enabled = false
  end

  ---Enable this bounce walk
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if this bounce walk is enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run render function on bounce walk
  function _self:render(dt, _)
    local pose = player:getPose()
    if _self.enabled and (pose == "STANDING" or pose == "CROUCHING") then
      local leftlegrot = vanilla_model.LEFT_LEG:getOriginRot()[1]
      local bounce = _self.bounceMultiplier
      if pose == "CROUCHING" then
        bounce = bounce / 2
      end
      _self.target = math.abs(leftlegrot) / 40 * bounce
    else
      _self.target = 0
    end
    model:setPos(0, math.lerp(model:getPos()[2], _self.target, dt), 0)
  end

  table.insert(squapi.bounceWalks, _self)
  return _self
end

---Contains all registered taurs
---@class SquAPI.Taurs
---@field private [number] SquAPI.Taur
squapi.taurs = {}
---@class SquAPI.Taur
squapi.taur = {}
squapi.taur.__index = squapi.taur

---TAUR PHYSICS - This will add some extra movement to taur-based models when you jump/fall.
---@param taurBody ModelPart The group of the body that contains all parts of the actual centaur part of the body, pivot should be placed near the connection between body and taurs body.
---@param frontLegs? ModelPart The group that contains both front legs.
---@param backLegs? ModelPart The group that contains both back legs.
---@return SquAPI.Taur
function squapi.taur:new(taurBody, frontLegs, backLegs)
  ---@class SquAPI.Taur
  local _self = setmetatable({}, squapi.taur)
  -- INIT -------------------------------------------------------------------------
  assert(taurBody, "§4Your model path for the body in taurPhysics is incorrect.§c")
  --assert(frontLegs, "§4Your model path for the front legs in taurPhysics is incorrect.§c")
  --assert(backLegs, "§4Your model path for the back legs in taurPhysics is incorrect.§c")
  _self.taurBody = taurBody
  _self.frontLegs = frontLegs
  _self.backLegs = backLegs
  _self.taur = squassets.BERP:new(0.01, 0.5)
  _self.target = 0

  -- CONTROL -------------------------------------------------------------------------
  _self.enabled = true
  ---Toggle this taur on or off
  function _self:toggle()
    _self.enabled = not _self.enabled
  end

  ---Disable this taur
  function _self:disable()
    _self.enabled = false
  end

  ---Enable this taur
  function _self:enable()
    _self.enabled = true
  end

  ---Sets if this taur is enabled
  ---@param bool boolean
  function _self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    _self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run tick function on taur
  function _self:tick()
    if _self.enabled then
      _self.target = math.min(math.max(-30, squassets.verticalVel() * 40), 45)
    end
  end

  ---Run render function on taur
  ---@param dt number Tick delta
  function _self:render(dt, _)
    if _self.enabled then
      _self.taur:berp(_self.target, dt / 2)
      local pose = player:getPose()

      if pose == "FALL_FLYING" or pose == "SWIMMING" or (player:isClimbing() and not player:isOnGround()) or player:riptideSpinning() then
        _self.taurBody:setRot(80, 0, 0)
        if _self.backLegs then
          _self.backLegs:setRot(-50, 0, 0)
        end
        if _self.frontLegs then
          _self.frontLegs:setRot(-50, 0, 0)
        end
      else
        _self.taurBody:setRot(_self.taur.pos, 0, 0)
        if _self.backLegs then
          _self.backLegs:setRot(_self.taur.pos * 3, 0, 0)
        end
        if _self.frontLegs then
          _self.frontLegs:setRot(-_self.taur.pos * 3, 0, 0)
        end
      end
    end
  end

  table.insert(squapi.taurs, _self)
  return _self
end

---Contains all registered first person hands
---@class SquAPI.FPHands
---@field private [number] SquAPI.FPHand
squapi.FPHands = {}
---@class SquAPI.FPHand
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
  local _self = setmetatable(self, squapi.FPHand)

  -- INIT -------------------------------------------------------------------------
  assert(element, "Your First Person Hand path is incorrect")
  element:setParentType("RightArm")
  _self.element = element
  _self.x = x or 0
  _self.y = y or 0
  _self.z = z or 0
  _self.scale = scale or 1
  _self.onlyVisibleInFP = onlyVisibleInFP

  -- CONTROL -------------------------------------------------------------------------

  ---Set this first person hand's position
  ---@param _x number X position
  ---@param _y number Y position
  ---@param _z number Z position
  function _self:updatePos(_x, _y, _z)
    _self.x = _x
    _self.y = _y
    _self.z = _z
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run render function on this first person hand
  ---@param context Event.Render.context
  function _self:render(_, context)
    if context == "FIRST_PERSON" then
      if _self.onlyVisibleInFP then
        _self.element:setVisible(true)
      end
      _self.element:setPos(_self.x, _self.y, _self.z)
      _self.element:setScale(_self.scale, _self.scale, _self.scale)
    else
      if _self.onlyVisibleInFP then
        _self.element:setVisible(false)
      end
      _self.element:setPos(0, 0, 0)
    end
  end

  table.insert(squapi.FPHands, _self)
  return _self
end

---Easy-use Animated Texture.
---@param element ModelPart The part of your model who's texture will be aniamted.
---@param numberOfFrames number The number of frames.
---@param framePercent number What percent width/height the uv takes up of the whole texture. For example: if there is a 100x100 texture, and the uv is 20x20, this will be .20
---@param slowFactor? number Defaults to `1`, increase this to slow down the animation.
---@param vertical? boolean Defaults to `false`, set to true if you'd like the animation frames to go down instead of right.
---@class SquAPI.AnimateTexture
function squapi.animateTexture(element, numberOfFrames, framePercent, slowFactor, vertical)
  assert(element,
    "§4Your model path for animateTexture is incorrect.§c")
  vertical = vertical or false
  slowFactor = slowFactor or 1
  function events.tick()
    local time = world.getTime()
    local frameshift = math.floor(time / slowFactor) % numberOfFrames * framePercent
    if vertical then element:setUV(0, frameshift) else element:setUV(frameshift, 0) end
  end
end

-- UPDATES ALL SQUAPI FEATURES --------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

if squapi.autoFunctionUpdates then
  function events.tick()
    for _, v in ipairs(squapi.smoothHeads) do v:tick() end
    for _, v in ipairs(squapi.eyes) do v:tick() end
    for _, v in ipairs(squapi.bewbs) do v:tick() end
    for _, v in ipairs(squapi.hoverPoints) do v:tick() end
    for _, v in ipairs(squapi.ears) do v:tick() end
    for _, v in ipairs(squapi.tails) do v:tick() end
    for _, v in ipairs(squapi.taurs) do v:tick() end
  end

  function events.render(dt, context)
    for _, v in ipairs(squapi.smoothHeads) do v:render(dt, context) end
    for _, v in ipairs(squapi.FPHands) do v:render(dt, context) end
    for _, v in ipairs(squapi.bounceWalks) do v:render(dt, context) end
    for _, v in ipairs(squapi.eyes) do v:render(dt, context) end
    for _, v in ipairs(squapi.bewbs) do v:render(dt, context) end
    for _, v in ipairs(squapi.hoverPoints) do v:render(dt, context) end
    for _, v in ipairs(squapi.ears) do v:render(dt, context) end
    for _, v in ipairs(squapi.tails) do v:render(dt, context) end
    for _, v in ipairs(squapi.taurs) do v:render(dt, context) end
  end
end







return squapi
