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

-- Require SquAssets
---@class SquAssets
local squassets
local assetPath = ... .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

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

-- Require modules
local concat, s = "%s.%s", "s"
local modules = { "tail", "ear", "crouch", "bewb", "randimation", "eye", "hoverPoint", "leg", "arm",
  "smoothHead", "bounceWalk", "taur", "FPHand", "animateTexture" }
local isTick = { smoothHead = true, eye = true, bewb = true, hoverPoint = true, ear = true, tail = true, taur = true }
local isRender = { smoothHead = true, FPHand = true, bounceWalk = true, eye = true, bewb = true, hoverPoint = true, ear = true, tail = true, taur = true }
local tickQueue, renderQueue = {}, {}
local tQueueIndex, rQueueIndex = 0, 0
local modulesPath = ... .. ".modules"

for _, value in pairs(modules) do
  local script = concat:format(modulesPath, value)
  if pcall(require, script) then
    squapi[value], squapi[value .. s] = require(script)
    if isTick[value] then
      tQueueIndex = tQueueIndex + 1
      tickQueue[tQueueIndex] = squapi[value .. s]
    end
    if isRender[value] then
      rQueueIndex = rQueueIndex + 1
      renderQueue[rQueueIndex] = squapi[value .. s]
    end
  end
end


-- UPDATES ALL SQUAPI FEATURES --------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

if squapi.autoFunctionUpdates then
  function events.tick()
    for i = 1, tQueueIndex do
      for _, v in ipairs(tickQueue[i]) do v:tick() end
    end
  end

  function events.render(dt, context)
    for i = 1, rQueueIndex do
      for _, v in ipairs(renderQueue[i]) do v:render(dt, context) end
    end
  end
end

return squapi
