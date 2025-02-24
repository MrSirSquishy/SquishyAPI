---@meta _
---@class SquAPI
local squapi = {}

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

return squapi.animateTexture