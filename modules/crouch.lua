---@meta _
local squassets
local assetPath = (...):gsub(".modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}

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

return squapi.crouch