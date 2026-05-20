---@meta _
local squassets
local assetPath = (...):gsub(".SquAPI_modules", "") .. ".SquAssets"
if pcall(require, assetPath) then squassets = require(assetPath) end
assert(squassets, "§4The hoverPoint module requires SquAssets, which was not found!§c")


---@class hoverPoint
local hoverPoint = {}
hoverPoint.all = {}

---*CONSTRUCTOR
---@param element ModelPart The element you are moving.
---@param elementOffset? Vector3 Defaults to `vec(0,0,0)`, the position of the hover point relative to you.
---@param springStrength? number Defaults to `0.2`, how strongly the object is pulled to it's original spot.
---@param mass? number Defaults to `5`, how heavy the object is (heavier accelerate/deccelerate slower).
---@param resistance? number Defaults to `1`, how much the elements speed decays (like air resistance).
---@param rotationSpeed? number Defaults to `0.05`, how fast the element should rotate to it's normal rotation.
---@param rotateWithPlayer? boolean Defaults to `true`, wheather or not the hoverPoint should rotate with you
---@param doCollisions? boolean Defaults to `false`, whether or not the element should collide with blocks (warning: the system is janky).
function hoverPoint:new(element, elementOffset, springStrength, mass, resistance, rotationSpeed, rotateWithPlayer, doCollisions)
    ---@class SquAPI.hoverPoint
    local self = {}

    self.element = element
    assert(self.element,"§4The Hover point's model path is incorrect.§c")
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

    self.pos = vec(0,0,0)
    self.vel = vec(0,0,0)
    self.init = true
    self.delay = 0
    
    self.enabled = true

    self = setmetatable(self, {__index = hoverPoint})
    table.insert(hoverPoint.all, self)
    return self
end


--*CONTROL FUNCTIONS

---hoverPoint enable handling
function hoverPoint:disable() self.enabled = false return self end
function hoverPoint:enable() self.enabled = true return self end
function hoverPoint:toggle() self.enabled = not self.enabled return self end

---@param bool boolean
function hoverPoint:setEnabled(bool)
    self.enabled = bool or false
    return self
end

function hoverPoint:reset()
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


--*UPDATE FUNCTIONS

function hoverPoint:tick()
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


---@param dt number Tick delta
function hoverPoint:render(dt, _)
    self.element:setPos(
      math.lerp(self.element:getPos(), self.pos * 16, dt / 2)
    )
    self.element:setOffsetRot(0,
      math.lerp(self.element:getOffsetRot()[2], 180-player:getBodyYaw(), dt * self.rotationSpeed), 0)
end



return hoverPoint