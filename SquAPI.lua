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

-- Version: 1.1.0
-- Legal: ARR

-- Special Thanks to
-- @jimmyhelp for errors and just generally helping me get things working.
-- FOX (@bitslayn) for overhauling annotations and clarity, and for fleshing out some functionality(fr big thanks)

-- IMPORTANT FOR NEW USERS!!! READ THIS!!!

-- Thank you for using SquAPI! Unless you're experienced and wish to actually modify the functionality
-- of this script, I wouldn't recommend snooping around.
-- Don't know exactly what you're doing? this site contains a guide on how to use!(also linked on github):
-- https://mrsirsquishy.notion.site/Squishy-API-Guide-3e72692e93a248b5bd88353c96d8e6c5

-- this SquAPI file does have some mini-documentation on paramaters if you need like a quick reference, but
-- do not modify, and do not copy-paste code from this file unless you are an avid scripter who knows what they are doing.


-- Don't be afraid to ask me for help, just make sure to provide as much info as possible so I or someone can help you faster.






--setup stuff

-- Locates SquAssets, if it exists
-- Written by FOX
---@class SquAssets
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
		self.tailSegmentList = {self.tailSegmentList}
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
      "§4The tail segment at position "..i.." of the table is not a group. The tail segments need to be groups that are nested inside the previous segment.§c")
      self.berps[i] = {squassets.BERP:new(self.stiffness, self.bounce), squassets.BERP:new(self.stiffness, self.bounce, self.downLimit, self.upLimit)}
      self.targets[i] = {0, 0}
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
          self.bodyRotSpeed = math.max(math.min(self.currentBodyRot-self.oldBodyRot, 20), -20)

          local time = world.getTime()
          local vel = squassets.forwardVel()
          local yvel = squassets.verticalVel()
          local svel = squassets.sideVel()
          local bendStrength = self.bendStrength/(math.abs((yvel*30))+vel*30 + 1)
          local pose = player:getPose()
      
          for i = 1, #self.tailSegmentList do
              self.targets[i][1] = math.sin((time * self.idleXSpeed)/10 - (i * self.offsetBetweenSegments)) * self.idleXMovement
              self.targets[i][2] = math.sin((time * self.idleYSpeed)/10 - (i * self.offsetBetweenSegments) + self.initialMovementOffset) * self.idleYMovement

              self.targets[i][1] = self.targets[i][1] + self.bodyRotSpeed*self.bendStrength + svel*self.bendStrength*40
              self.targets[i][2] = self.targets[i][2] + yvel * 15 * self.bendStrength - vel*self.bendStrength*15*self.velocityPush

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

---Contains all registered ears
---@type SquAPI.Ear[]
squapi.ears = {}
squapi.ear = {}
squapi.ear.__index = squapi.ear

---EAR PHYSICS - this adds physics to your ear(s) when you move, and has options for different ear types.
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
  local self = setmetatable({}, squapi.ear)

  -- INIT -------------------------------------------------------------------------

  assert(leftEar,
    "§4The first ear's model path is incorrect.§c")
  self.leftEar = leftEar
  self.rightEar = rightEar
  self.horizontalEars = horizontalEars
  self.rangeMultiplier = rangeMultiplier or 1
  if self.horizontalEars then self.rangeMultiplier = self.rangeMultiplier / 2 end
  self.bendStrength = bendStrength or 2
  earStiffness = earStiffness or 0.1
  earBounce = earBounce or 0.8

  if doEarFlick == nil then doEarFlick = true end
  self.doEarFlick = doEarFlick
  self.earFlickChance = earFlickChance or 400

  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  ---Toggle this ear on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disable this ear
  function self:disable()
    self.enabled = false
  end

  ---Enable this ear
  function self:enable()
    self.enabled = true
  end

  ---Sets if this ear is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  self.eary = squassets.BERP:new(earStiffness, earBounce)
  self.earx = squassets.BERP:new(earStiffness, earBounce)
  self.earz = squassets.BERP:new(earStiffness, earBounce)
  self.targets = { 0, 0, 0 }
  self.oldpose = "STANDING"

  ---Run tick function on ear
  function self:tick()
    if self.enabled then
      local vel = math.min(math.max(-0.75, squassets.forwardVel()), 0.75)
      local yvel = math.min(math.max(-1.5, squassets.verticalVel()), 1.5) * 5
      local svel = math.min(math.max(-0.5, squassets.sideVel()), 0.5)
      local headrot = squassets.getHeadRot()
      local bend = self.bendStrength
      if headrot[1] < -22.5 then bend = -bend end

      --gives the ears a short push when crouching/uncrouching
      local pose = player:getPose()
      if pose == "CROUCHING" and self.oldpose == "STANDING" then
        self.eary.vel = self.eary.vel + 5 * self.bendStrength
      elseif pose == "STANDING" and self.oldpose == "CROUCHING" then
        self.eary.vel = self.eary.vel - 5 * self.bendStrength
      end
      self.oldpose = pose

      --main physics
      if self.horizontalEars then
        local rot = 10 * bend * (yvel + vel * 10) + headrot[1] * self.rangeMultiplier
        local addrot = headrot[2] * self.rangeMultiplier
        self.targets[2] = rot + addrot
        self.targets[3] = -rot + addrot
      else
        self.targets[1] = headrot[1] * self.rangeMultiplier + 2 * bend * (yvel + vel * 15)
        self.targets[2] = headrot[2] * self.rangeMultiplier - svel * 100 * self.bendStrength
        self.targets[3] = self.targets[2]
      end

      --ear flicking
      if self.doEarFlick then
        if math.random(0, self.earFlickChance) == 1 then
          if math.random(0, 1) == 1 then
            self.earx.vel = self.earx.vel + 50
          else
            self.earz.vel = self.earz.vel - 50
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
  function self:render(dt, _)
    if self.enabled then
      self.eary:berp(self.targets[1], dt)
      self.earx:berp(self.targets[2], dt)
      self.earz:berp(self.targets[3], dt)

      local rot3 = self.earx.pos / 4
      local rot3b = self.earz.pos / 4

      if self.horizontalEars then
        local y = self.eary.pos / 4
        self.leftEar:setOffsetRot(y, self.earx.pos / 3, rot3)
        if self.rightEar then
          self.rightEar:setOffsetRot(y, self.earz.pos / 3, rot3b)
        end
      else
        self.leftEar:setOffsetRot(self.eary.pos, rot3, rot3)
        if self.rightEar then
          self.rightEar:setOffsetRot(self.eary.pos, rot3b, rot3b)
        end
      end
    end
  end

  table.insert(squapi.ears, self)
  return self
end

---CROUCH ANIMATION - this allows you to set an animation for your crouch (this can either be a static pose for crouching, or an animation to transition to crouching)<br><br>It also allows you to optionally set an uncrouch animation, and includes the same features mentioned for crawling if you need as well.
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
---@type SquAPI.Bewb[]
squapi.bewbs = {}
squapi.bewb = {}
squapi.bewb.__index = squapi.bewb

---BEWB PHYSICS - this can add bewb physics to your avatar, which for some reason is also versatile for non-tiddy related activities.
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
  local self = setmetatable({}, squapi.bewb)

  -- INIT -------------------------------------------------------------------------
  assert(element, "§4Your model path for bewb is incorrect.§c")
  self.element = element
  if doIdle == nil then doIdle = true end
  self.doIdle = doIdle
  self.bendability = bendability or 2
  self.bewby = squassets.BERP:new(stiff or 0.05, bounce or 0.9, downLimit or -10, upLimit or 25)
  self.idleStrength = idleStrength or 4
  self.idleSpeed = idleSpeed or 1
  self.target = 0

  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  ---Toggle these bewbs on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disable these bewbs
  function self:disable()
    self.enabled = false
  end

  ---Enable these bewbs
  function self:enable()
    self.enabled = true
  end

  ---Sets if these bewbs are enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  -- UPDATE -------------------------------------------------------------------------

  self.oldpose = "STANDING"
  ---Run tick function on bewbs
  function self:tick()
    if self.enabled then
      local vel = squassets.forwardVel()
      local yvel = squassets.verticalVel()
      local worldtime = world.getTime()

      if self.doIdle then
        self.target = math.sin(worldtime / 8 * self.idleSpeed) * self.idleStrength
      end

      --physics when crouching/uncrouching
      local pose = player:getPose()
      if pose == "CROUCHING" and self.oldpose == "STANDING" then
        self.bewby.vel = self.bewby.vel + self.bendability
      elseif pose == "STANDING" and self.oldpose == "CROUCHING" then
        self.bewby.vel = self.bewby.vel - self.bendability
      end
      self.oldpose = pose

      --physics when moving
      self.bewby.vel = self.bewby.vel - yvel * self.bendability
      self.bewby.vel = self.bewby.vel - vel * self.bendability
    else
      self.target = 0
    end
  end

  ---Run render function on bewbs
  ---@param dt number Tick delta
  function self:render(dt, _)
    self.element:setOffsetRot(self.bewby:berp(self.target, dt), 0, 0)
  end

  table.insert(squapi.bewbs, self)
  return self
end

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
function squapi.hoverPoint:new(element, elementOffset, springStrength, mass, resistance, rotationSpeed, rotateWithPlayer, doCollisions)
  ---@class SquAPI.HoverPoint
  local self = setmetatable({}, squapi.hoverPoint)

  -- INIT -------------------------------------------------------------------------
  self.element = element
  assert(self.element,
    "§4The Hover point's model path is incorrect.§c")
  self.element:setParentType("WORLD")
  elementOffset = elementOffset or vec(0,0,0)
  self.elementOffset = elementOffset*16
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
        cos*self.elementOffset.x - sin*self.elementOffset.z, 
        self.elementOffset.y,
        sin*self.elementOffset.x + cos*self.elementOffset.z
    )
    self.pos = player:getPos() + offset/16
    self.element:setPos(self.pos*16)
    self.element:setOffsetRot(0,-player:getBodyYaw()+180,0)
end

self.pos = vec(0,0,0)
self.vel = vec(0,0,0)

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
            cos*self.elementOffset.x - sin*self.elementOffset.z, 
            self.elementOffset.y,
            sin*self.elementOffset.x + cos*self.elementOffset.z
        )

        if self.init then
            self.init = false
            self.pos = player:getPos() + offset/16
            self.element:setPos(self.pos*16)
            self.element:setOffsetRot(0,-player:getBodyYaw()+180,0)
        end

        --adjusts the target based on the players rotation
        local target = player:getPos() + offset/16
        local pos = self.element:partToWorldMatrix():apply()
        local dif = self.pos - target

        local force = vec(0,0,0)

        if self.delay == 0 then
            --behold my very janky collision system
            if self.doCollisions and world.getBlockState(pos):getCollisionShape()[1] then
                local block, hitPos, side = raycast:block(pos-self.vel*2, pos)
                self.pos = self.pos + (hitPos - pos)
                if side == "east" or side == "west" then
                    self.vel.x = -self.vel.x*0.5
                elseif side == "north" or side == "south" then
                    self.vel.z = -self.vel.z*0.5
                else
                    self.vel.y = -self.vel.y*0.5
                end
                self.delay = 2
            else
                force = force - dif*self.springStrength --spring force
            end
        else
            self.delay = self.delay - 1
        end
        force = force -self.vel*self.resistance --resistive force(based on air resistance)
        
        self.vel = self.vel + force/self.mass
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
      math.lerp(self.element:getOffsetRot()[2], 180-player:getBodyYaw(), dt * self.rotationSpeed), 0)
  end

  table.insert(squapi.hoverPoints, self)
  return self
end

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

---Contains all registered arms
---@type SquAPI.Arm[]
squapi.arms = {}
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
  local self = squassets.vanillaElement:new(element, strength, keepPosition)

  -- INIT -------------------------------------------------------------------------
  if isRight == nil then isRight = false end
  self.isRight = isRight

  -- CONTROL -------------------------------------------------------------------------

  --inherits functions from squassets.vanillaElement

  -- UPDATES -------------------------------------------------------------------------

  ---Returns the vanilla arm rotation and position vectors
  ---@return Vector3 #Vanilla arm rotation
  ---@return Vector3 #Vanilla arm position
  function self:getVanilla()
    if self.isRight then
      self.rot = vanilla_model.RIGHT_ARM:getOriginRot()
    else
      self.rot = vanilla_model.LEFT_ARM:getOriginRot()
    end
    self.pos = -vanilla_model.LEFT_ARM:getOriginPos()
    return self.rot, self.pos
  end

  table.insert(squapi.arms, self)
  return self
end

---Contains all registered smooth heads
---@type SquAPI.SmoothHead[]
squapi.smoothHeads = {}
squapi.smoothHead = {}
squapi.smoothHead.__index = squapi.smoothHead

---SMOOTH HEAD - Mimics a vanilla player head, but smoother and with some extra life. Can also do smooth Torsos and Smooth Necks!
---@param element ModelPart|table<ModelPart> The head element that you wish to effect. If you want a smooth neck or torso, instead of a single element, input a table of head elements(imagine it like {element1, element2, etc.}). this will apply the head rotations to each of these.
---@param strength? number|table<number> Defaults to `1`, the target rotation is multiplied by this factor. If you want a smooth neck or torso, instead of an single number, you can put in a table(imagine it like {strength1, strength2, etc.}). this will apply each strength to each respective element.(make sure it is the same length as your element table)
---@param tilt? number Defaults to `0.1`, for context the smooth head applies a slight tilt to the head as it's rotated toward the side, this controls the strength of that tilt.
---@param speed? number Defaults to `1`, how fast the head will rotate toward the target rotation.
---@param keepOriginalHeadPos? boolean|number Defaults to `true`, when true the heads position will follow the vanilla head position. For example when crouching the head will shift down to follow. If set to a number, changes which modelpart gets moved when doing actions such as crouching. this should normally be set to the neck modelpart.
---@param fixPortrait? boolean Defaults to `true`, sets whether or not the portrait should be applied if a group named "head" is found in the elements list
function squapi.smoothHead:new(element, strength, tilt, speed, keepOriginalHeadPos, fixPortrait)
  ---@class SquAPI.SmoothHead
  local self = setmetatable({}, squapi.smoothHead)

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
  self.element = element

  self.strength = strength or 1
  if type(self.strength) == "number" then
    local strengthDiv = self.strength / #element
    self.strength = {}
    for i = 1, #element do
      self.strength[i] = strengthDiv
    end
  end

  self.tilt = tilt or 0.1
  if keepOriginalHeadPos == nil then keepOriginalHeadPos = true end
  self.keepOriginalHeadPos = keepOriginalHeadPos
  self.headRot = vec(0, 0, 0)
  self.offset = vec(0, 0, 0)
  self.speed = (speed or 1) / 2

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
  function self:setOffset(xRot, yRot, zRot)
    self.offset = vec(xRot, yRot, zRot)
  end

  self.enabled = true
  ---Toggles this smooth head on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disables this smooth head
  function self:disable()
    self.enabled = false
  end

  ---Enables this smooth head
  function self:enable()
    self.enabled = true
  end

  ---Sets if this smooth head is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  ---Resets this smooth head's position and rotation to their initial values
  function self:zero()
    for _, v in ipairs(self.element) do
      v:setPos(0, 0, 0)
      v:setOffsetRot(0, 0, 0)
      self.headRot = vec(0, 0, 0)
    end
  end

  -- UPDATE -------------------------------------------------------------------------

  ---Run tick function on smooth head
  function self:tick()
    if self.enabled then
      local vanillaHeadRot = squassets.getHeadRot()

      self.headRot[1] = self.headRot[1] + (vanillaHeadRot[1] - self.headRot[1]) * self.speed
      self.headRot[2] = self.headRot[2] + (vanillaHeadRot[2] - self.headRot[2]) * self.speed
      self.headRot[3] = self.headRot[2] * self.tilt
    end
  end

  ---Run render function on smooth head
  ---@param dt number Tick delta
  ---@param context Event.Render.context
  function self:render(dt, context)
    if self.enabled then
      dt = dt / 5
      for i in ipairs(self.element) do
        local c = self.element[i]:getOffsetRot()
        local target = (self.headRot * self.strength[i]) - self.offset / #self.element
        self.element[i]:setOffsetRot(
          math.lerp(c[1], target[1], dt), 
          math.lerp(c[2], target[2], dt),
          math.lerp(c[3], target[3], dt)
        )

        -- Better Combat SquAPI Compatibility created by @jimmyhelp and @foxy2526 on Discord
        if renderer:isFirstPerson() and context == "RENDER" then
          self.element[i]:setVisible(false)
        else
          self.element[i]:setVisible(true)
        end
      end

      if self.keepOriginalHeadPos then
        self.element
            [type(self.keepOriginalHeadPos) == "number" and self.keepOriginalHeadPos or #self.element]
            :setPos(-vanilla_model.HEAD:getOriginPos())
      end
    end
  end

  table.insert(squapi.smoothHeads, self)
  return self
end

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

---Contains all registered taurs
---@type SquAPI.Taur[]
squapi.taurs = {}
squapi.taur = {}
squapi.taur.__index = squapi.taur

---TAUR PHYSICS - this will add some extra movement to taur-based models when you jump/fall.
---@param taurBody ModelPart The group of the body that contains all parts of the actual centaur part of the body, pivot should be placed near the connection between body and taurs body.
---@param frontLegs? ModelPart The group that contains both front legs.
---@param backLegs? ModelPart The group that contains both back legs.
---@return SquAPI.Taur
function squapi.taur:new(taurBody, frontLegs, backLegs)
  ---@class SquAPI.Taur
  local self = setmetatable({}, squapi.taur)
  -- INIT -------------------------------------------------------------------------
  assert(taurBody, "§4Your model path for the body in taurPhysics is incorrect.§c")
  --assert(frontLegs, "§4Your model path for the front legs in taurPhysics is incorrect.§c")
  --assert(backLegs, "§4Your model path for the back legs in taurPhysics is incorrect.§c")
  self.taurBody = taurBody
  self.frontLegs = frontLegs
  self.backLegs = backLegs
  self.taur = squassets.BERP:new(0.01, 0.5)
  self.target = 0

  -- CONTROL -------------------------------------------------------------------------
  self.enabled = true
  ---Toggle this taur on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disable this taur
  function self:disable()
    self.enabled = false
  end

  ---Enable this taur
  function self:enable()
    self.enabled = true
  end

  ---Sets if this taur is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  ---Run tick function on taur
  function self:tick()
    if self.enabled then
      self.target = math.min(math.max(-30, squassets.verticalVel() * 40), 45)
    end
  end

  ---Run render function on taur
  ---@param dt number Tick delta
  function self:render(dt, _)
    if self.enabled then
      self.taur:berp(self.target, dt / 2)
      local pose = player:getPose()

      if pose == "FALL_FLYING" or pose == "SWIMMING" or (player:isClimbing() and not player:isOnGround()) or player:riptideSpinning() then
        self.taurBody:setRot(80, 0, 0)
        if self.backLegs then
          self.backLegs:setRot(-50, 0, 0)
        end
        if self.frontLegs then
          self.frontLegs:setRot(-50, 0, 0)
        end
      else
        self.taurBody:setRot(self.taur.pos, 0, 0)
        if self.backLegs then
          self.backLegs:setRot(self.taur.pos * 3, 0, 0)
        end
        if self.frontLegs then
          self.frontLegs:setRot(-self.taur.pos * 3, 0, 0)
        end
      end
    end
  end

  table.insert(squapi.taurs, self)
  return self
end

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
    for _, v in ipairs(squapi.legs) do v:render(dt, context) end
    for _, v in ipairs(squapi.arms) do v:render(dt, context) end
  end
end







return squapi
