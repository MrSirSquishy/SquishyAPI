--[[--------------------------------------------------------------------------------------
  ____              _     _                _                 _       
 / ___|  __ _ _   _(_)___| |__  _   _     / \   ___ ___  ___| |_ ___ 
 \___ \ / _` | | | | / __| '_ \| | | |   / _ \ / __/ __|/ _ \ __/ __|
  ___) | (_| | |_| | \__ \ | | | |_| |  / ___ \\__ \__ \  __/ |_\__ \
 |____/ \__, |\__,_|_|___/_| |_|\__, | /_/   \_\___/___/\___|\__|___/
           |_|                  |___/                                                           
--]]--------------------------------------------------------------------------------------Standard

--[[
-- Author: Squishy
-- Discord tag: @mrsirsquishy

-- Version: 1.0.0 
-- Legal: ARR

Framework Functions and classes for SquAPI. 
This contains some math functions, some simplified calls to figura features, some debugging scripts for convenience, and classes used in SquAPI or for debugging.

You can also make use of these functions, however it's for more advanced scripters. remember to call: local squassets = require("SquAssets")


]]



local squassets = {}

--Useful Calls
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--detects the fluid the player is in(air is nil), and if they are fully submerged in that fluid.
--vanilla player has an eye height of 1.5 which is used by default for checking if it's submerged, but you can optionally modify this for different height avatars
function squassets.getFluid(eyeHeight)
	local fluid
	local B = world.getBlockState(player:getPos() + vec(0, eyeHeight or 1.5, 0))
	local submerged = B.id == "minecraft:water" or B.id == "minecraft:lava"

	if player:isInWater() then 
		fluid = "WATER" 
	elseif player:isInLava() then 
		fluid = "LAVA" 
	end
	return fluid, submerged
end

--better isOnGround, taken from the figura wiki
function squassets.isOnGround()
	return world.getBlockState(thisEntity:getPos():add(0, -0.1, 0)):isSolidBlock()
end

-- returns how fast the player moves forward, negative means backward
function squassets.forwardVel()
	return player:getVelocity():dot((player:getLookDir().x_z):normalize())
end

-- returns y velocity(negative is down)
function squassets.verticalVel()
	return player:getVelocity()[2]
end

-- returns how fast player moves sideways, negative means left
-- Courtesy of @auriafoxgirl on discord
function squassets.sideVel()
	return (player:getVelocity() * matrices.rotation3(0, player:getRot().y, 0)).x
end

--returns a cleaner vanilla head rotation value to use
function squassets.getHeadRot()
	return (vanilla_model.HEAD:getOriginRot()+180)%360-180
end




--Math Functions
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--polar to cartesian coordiantes
function squassets.PTOC(r, theta)
	return r*math.cos(theta), r*math.sin(theta)
end

--cartesian to polar coordinates
function squassets.CTOP(x, y)
	return squassets.pyth(x, y), math.atan(y/x)
end

--3D polar to cartesian coordiantes(returns vec3)
function squassets.PTOC3(R, theta, phi)
	local r, y = squassets.PTOC(R, phi)
	local x, z = squassets.PTOC(r, theta)
	return vec(x, y, z)
end

--3D cartesian to polar coordinates
function squassets.CTOP3(x, y, z)
	local v
	if type(x) == "Vector3" then
		v = x
	else
		v = vec(x, y, z)
	end
	local R = v:length()

	return R, math.atan2(v.z, v.x), math.asin(v.y/R)
end

--pythagorean theoremn
function squassets.pyth(a, b)
	return math.sqrt(a^2 + b^2)
end


--checks if a point is within a box
function squassets.pointInBox(point, corner1, corner2)
	if not (point and corner1 and corner2) then return false end
	return
	point.x >= corner1.x and point.x <= corner2.x and
    point.y >= corner1.y and point.y <= corner2.y and
    point.z >= corner1.z and point.z <= corner2.z 
end

--returns true if the number is within range, false otherwise
function squassets.inRange(lower, num, upper)
	return lower <= num and num <= upper
end

-- Linear graph
-- locally generates a graph between two points, returns the y value at t on that graph
function squassets.lineargraph(x1, y1, x2, y2, t)
	local slope = (y2-y1)/(x2-x1)
	local inter = y2 - slope*x2
	return slope*t + inter
end

--Parabolic graph
--locally generates a parabolic graph between three points, returns the y value at t on that graph
function squassets.parabolagraph(x1, y1, x2, y2, x3, y3, t)
    local denom = (x1 - x2) * (x1 - x3) * (x2 - x3)
    
	local a = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / denom
    local b = (x3^2 * (y1 - y2) + x2^2 * (y3 - y1) + x1^2 * (y2 - y3)) / denom
    local c = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / denom

    return a * t^2 + b * t + c
end

--returns 1 if num is >= 0, returns -1 if less than 0
function squassets.sign(num)
	if num < 0 then
		return -1
	end
	return 1
end

--returns a vector with the signs of each vector(shows the direction of each vector)
function squassets.Vec3Dir(v)
	return vec(squassets.sign(v.x), squassets.sign(v.y), squassets.sign(v.z))
end

--raises all values in a vector to a power
function squassets.Vec3Pow(v, power)
	local power = power or 2
	return vec(math.pow(v.x, power), math.pow(v.y, power), math.pow(v.z, power))
end








--Debug/Display Functions
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--displays the corners of a bounding box, good for debugging
---@param corner1 vector coordinate of first corner
---@param corner2 vector coordinate of second corner
---@param color vector of the color, or a string of one of the preset colors
function squassets.bbox(corner1, corner2, color)
	dx = corner2[1] - corner1[1]
	dy = corner2[2] - corner1[2]
	dz = corner2[3] - corner1[3]
	squassets.pointMarker(corner1, color)
	squassets.pointMarker(corner2, color)
	squassets.pointMarker(corner1 + vec(dx,0,0), color)
	squassets.pointMarker(corner1 + vec(dx,dy,0), color)
	squassets.pointMarker(corner1 + vec(dx,0,dz), color)
	squassets.pointMarker(corner1 + vec(0,dy,0), color)
	squassets.pointMarker(corner1 + vec(0,dy,dz), color)
	squassets.pointMarker(corner1 + vec(0,0,dz), color)
end


--draws a sphere
function squassets.sphereMarker(pos, radius, color, colorCenter, quality)
	local pos = pos or vec(0, 0, 0)
	local r = radius or 1
	local quality = (quality or 1)*10
	local colorCenter = colorCenter or color


	-- Draw the center point
	squassets.pointMarker(pos, colorCenter)

	-- Draw surface points
	for i = 1, quality do
		for j = 1, quality do
			local theta = (i / quality) * 2 * math.pi
			local phi = (j / quality) * math.pi

			local x = pos.x + r * math.sin(phi) * math.cos(theta)
			local y = pos.y + r * math.sin(phi) * math.sin(theta)
			local z = pos.z + r * math.cos(phi)

			squassets.pointMarker(vec(x, y, z), color)
		end
	end
end

--draws a line between two points with particles, higher density is more particles
function squassets.line(corner1, corner2, color, density)
    local l = (corner2 - corner1):length() -- Length of the line
    local direction = (corner2 - corner1):normalize() -- Direction vector
	local density = density or 10

    for i = 0, l, 1/density do
        local pos = corner1 + direction * i -- Interpolate position
        squassets.pointMarker(pos, color) -- Create a particle at the interpolated position
    end
end

--displays a particle at a point, good for debugging
---@param pos vector coordinate where it will render
---@param color vector of the color, or a string of one of the preset colors
function squassets.pointMarker(pos, color)
	if type(color) == "string" then
		if 	   color == "R" then color = vec(1, 0, 0) 
		elseif color == "G" then color = vec(0, 1, 0) 
		elseif color == "B" then color = vec(0, 0, 1) 
		elseif color == "yellow" then color = vec(1, 1, 0) 
		elseif color == "purple" then color = vec(1, 0, 1) 
		elseif color == "cyan" then color = vec(0, 1, 1) 
		elseif color == "black" then color = vec(0, 0, 0) 
		else
			color = vec(1,1,1)
		end
	else
		color = color or vec(1,1,1)
	end
	particles:newParticle("minecraft:wax_on", pos):setSize(0.5):setLifetime(0):setColor(color)
end









--Classes
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

squassets.vanillaElement = {}
squassets.vanillaElement.__index = squassets.vanillaElement
function squassets.vanillaElement:new(element, strength, keepPosition)
	local self = setmetatable({}, squassets.vanillaElement)

	-- INIT -------------------------------------------------------------------------
    self.keepPosition = keepPosition 
	if keepPosition == nil then self.keepPosition = true end
	self.element = element
	self.element:setParentType("NONE")
    self.strength = strength or 1
	self.rot = vec(0,0,0)
	self.pos = vec(0,0,0)

    -- CONTROL -------------------------------------------------------------------------

	self.enabled = true
    function self:disable()
        self.enabled = false
    end
    function self:enable()
        self.enabled = true
    end
	function self:toggle()
		self.enabled = not self.enabled
	end
    --returns it to normal attributes
    function self:zero()
        self.element:setOffsetRot(0, 0, 0)
		self.element:setPos(0, 0, 0)
    end
	--get the current rot/pos
	function self:getPos()
		return self.pos
	end
	function self:getRot()
		return self.rot
	end

    -- UPDATES -------------------------------------------------------------------------

    function self:render(dt, context)
        if self.enabled then
            local rot, pos = self:getVanilla()
            self.element:setOffsetRot(rot*self.strength)
			if self.keepPosition then
				self.element:setPos(pos)
			end
        end
    end

	return self
end

squassets.BERP3D = {}
squassets.BERP3D.__index = squassets.BERP3D
function squassets.BERP3D:new(stiff, bounce, lowerLimit, upperLimit, initialPos, initialVel)
	local self = setmetatable({}, squassets.BERP3D)

	self.stiff = stiff or 0.1
	self.bounce = bounce or 0.1
	self.pos = initialPos or vec(0, 0, 0)
	self.vel = initialVel or vec(0, 0, 0)
	self.acc = vec(0, 0, 0)
	self.lower = lowerLimit or {nil, nil, nil}
	self.upper = upperLimit or {nil, nil, nil}

	--target is the target position
	--dt, or delta time, the time between now and the last update(delta from the events.update() function)
	--if you want it to have a different stiff or bounce when run input a different stiff bounce
	function self:berp(target, dt, stiff, bounce)
		local target = target or vec(0,0,0)
		local dt = dt or 1

		for i = 1, 3 do
			--certified bouncy math
			local dif = (target[i]) - self.pos[i]
			self.acc[i] = ((dif * math.min(stiff or self.stiff, 1)) * dt) --based off of spring force F = -kx
			self.vel[i] = self.vel[i] + self.acc[i]

			--changes the position, but adds a bouncy bit that both overshoots and decays the movement
			self.pos[i] = self.pos[i] + (dif * (1-math.min(bounce or self.bounce, 1)) + self.vel[i]) * dt
			
			--limits range

			if self.upper[i] and self.pos[i] > self.upper[i] then
				self.pos[i] = self.upper[i]
				self.vel[i] = 0
			elseif self.lower[i] and self.pos[i] < self.lower[i] then
				self.pos[i] = self.lower
				self.vel[i] = 0
			end
		end

		--returns position so that you can immediately apply the position as it is changed. 
		return self.pos
	end

	return self
end



--stiffness factor, > 0
--bounce factor, reccomended when in range of 0-1. bigger is bouncier.
--if you want to limit the positioning, use lowerlimit and upperlimit, or leave nil
squassets.BERP = {}
squassets.BERP.__index = squassets.BERP
function squassets.BERP:new(stiff, bounce, lowerLimit, upperLimit, initialPos, initialVel)
	local self = setmetatable({}, squassets.BERP)

	self.stiff = stiff or 0.1
	self.bounce = bounce or 0.1
	self.pos = initialPos or 0
	self.vel = initialVel or 0
	self.acc = 0
	self.lower = lowerLimit or nil
	self.upper = upperLimit or nil

	--target is the target position
	--dt, or delta time, the time between now and the last update(delta from the events.update() function)
	--if you want it to have a different stiff or bounce when run input a different stiff bounce
	function self:berp(target, dt, stiff, bounce)
		local dt = dt or 1

		--certified bouncy math
		local dif = (target or 10) - self.pos
		self.acc = ((dif * math.min(stiff or self.stiff, 1)) * dt) --based off of spring force F = -kx
		self.vel = self.vel + self.acc

		--changes the position, but adds a bouncy bit that both overshoots and decays the movement
		self.pos = self.pos + (dif * (1-math.min(bounce or self.bounce, 1)) + self.vel) * dt
		
		--limits range

		if self.upper and self.pos > self.upper then
			self.pos = self.upper
			self.vel = 0
		elseif self.lower and self.pos < self.lower then
			self.pos = self.lower
			self.vel = 0
		end

		--returns position so that you can immediately apply the position as it is changed. 
		return self.pos
	end



	return self
end	


return squassets