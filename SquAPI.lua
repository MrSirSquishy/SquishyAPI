
--███████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗██╗   ██╗███████╗     █████╗ ██████╗ ██╗
--██╔════╝██╔═══██╗██║   ██║██║██╔════╝██║  ██║╚██╗ ██╔╝██╔════╝    ██╔══██╗██╔══██╗██║
--███████╗██║   ██║██║   ██║██║███████╗███████║ ╚████╔╝ ███████╗    ███████║██████╔╝██║
--╚════██║██║▄▄ ██║██║   ██║██║╚════██║██╔══██║  ╚██╔╝  ╚════██║    ██╔══██║██╔═══╝ ██║
--███████║╚██████╔╝╚██████╔╝██║███████║██║  ██║   ██║   ███████║    ██║  ██║██║     ██║
--╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝     ╚═╝
----------------------------------------------------------------------------------------

-- Author: Squishy
-- Discord tag: mrsirsquishy

-- Version: in-dev
-- Legal: Do not Redistribute without explicit permission.


local squapi = {}



squapi.bounceObject = {}
function squapi.bounceObject:new(stiff, bounce, pos, o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.vel = 0
	self.pos = pos or 0
	self.stiff = stiff or .005
	self.bounce = bounce or .08
	return o
end	
function squapi.bounceObject:doBounce(target)
	target = target or 2
	local dif = target - self.pos
	self.vel = self.vel + ((dif - self.vel * self.stiff) * self.stiff)
	self.pos = (self.pos + self.vel) + (dif * self.bounce)
	return self.pos
end


--BOUNCY EARS
--guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: the ear element that you want to affect(models.[modelname].path)
-- *element2: the second element you'd like to use(second ear), set to nil or leave empty to ignore
-- *bendstrength: how strong the ears bend when you move(jump, fall, run, etc.)
-- *earstiffness: how stiff the ears movement is(0-1)
-- *earbounce: how bouncy the ears are(0-1)

function squapi.ear(element, element2, bendstrength, earstiffness, earbounce)
	local element2 = element2 or nil
	local bendstrength = bendstrength or 2
	local earstiffness = earstiffness or 0.025
	local earbounce = earbounce or 0.1
	
	squapi.eary = squapi.bounceObject:new(earstiffness, earbounce)
	squapi.earx = squapi.bounceObject:new(earstiffness, earbounce)
	
	local oldpose = "STANDING"
	function events.render(delta, context)
		local vel = player:getVelocity():dot((player:getLookDir().x_z):normalize())
		local yvel = player:getVelocity()[2]
		local headrot = vanilla_model.HEAD:getOriginRot()
		headrot = squapi.exorcise(headrot)
		
		local bend = bendstrength
		if headrot[1] < -22.5 then bend = -bend end
		
		--moves when player crouches
		local pose = player:getPose()
		if pose == "CROUCHING" and oldpose == "STANDING" then
			squapi.eary.vel = squapi.eary.vel + 10
		end
		oldpose = pose
		
		--y vel change
		squapi.eary.vel = squapi.eary.vel + yvel * bend
		--x vel change
		squapi.eary.vel = squapi.eary.vel + vel * bend * 1.5
		
		local rot1 = squapi.eary:doBounce(headrot[1])
		local rot2 = squapi.earx:doBounce(headrot[2])
		local rot3 = rot2/3
		
		element:setRot(rot1 + 45, rot2/4, rot3)

		if not element2 ~= nil then 
			element2:setRot(rot1 + 45, rot2/4, rot3) 
		end
	end
end

-- Simplified Animated Texture script.
-- element: 		the part of your model who's texture will be aniamted
-- numberofframes: 	the number of frames
-- framepercent:	what percent width/height the uv takes up of the whole texture. for example: if there is a 100x100 texture, and the uv is 20x20, this will be .20
-- slowfactor: 		increase this to slow down the animation. 
function squapi.animateTexture(element, numberofframes, framepercent, slowfactor, vertical)
	function events.tick()
		vertical = vertical or false
		frameslowfactor = slowfactor or 1
		local time = world.getTime()
		local frameshift = math.floor(time/frameslowfactor)%numberofframes*framepercent
		if vertical then element:setUV(0, frameshift) else element:setUV(frameshift, 0) end
	end
end


-- Repairs incorrect head rotations
function squapi.exorcise(headrot)
	-- prevents demonic possesion
	while(headrot[2] > 90)
	do
		headrot[2] = headrot[2] - 360
	end
	while(headrot[2] < -90)
	do
		headrot[2] = headrot[2] + 360
	end

	while(headrot[1] > 100)
	do
		headrot[1] = headrot[1] - 360
	end
	while(headrot[1] < -100)
	do
		headrot[1] = headrot[1] + 360
	end
	return headrot
end


function squapi.setFirstPersonHandPos(element, x, y, z)
	function events.Render(delta, context)
		if context == "FIRST_PERSON" then 
			element:setPos(x, y, z)
		else 
			element:setPos(0, 0, 0) end
	end
end


--THE JUNKYARD. Old, unfinished, or scrapped stuff. Don't use these, but you can climb around I guess
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------



--LEGACY FOR OLDER STUFF. USE bounceObject INSTEAD
--1: dif is the distance between current and target
--2: lower vals of stiff mean that it is slower(lags behind more) 
--   This means slower acceleration. This acceleration is then added to vel.
--4: apply velocity to the current value, as well as adding bounce factor.
--5: returns the new value, as well as the velocity at that moment.

--Paramter details:
-- current: the current value(like position, rotation, etc.) of object that will be moved.
-- target: the target value - this is what it will bounce towards
-- stiff: how stiff it should be(between 0-1)
-- bounce: how bouncy it should be(between 0-1)
-- vel: the current velocity of the current value.

-- Returns the new position and new velocity.
function squapi.bouncetowards(current, target, stiff, bounce, vel)	
	local dif = target - current
	vel = vel + ((dif - vel * stiff) * stiff)
	current = (current + vel) + (dif * bounce)
	return current, vel
end


-- How to use
-- inside of events.render(delta, context) is where this function goes(squapi.earhysics())
-- the input paramaters:
-- element: 				the model path of the ear
-- earvel1 and earvel2: 	the input velocity variables to store the ears velocity
-- add two variables to your script, perferable called earvel1 and earvel2(though you can name them whatever), and set them to 0
-- call the function as: earvel1, earvel2 = squapi.earphysics(paramter stuff) - or whatever earvel1 and earvel2 are called
-- bendstrength: 			how strong the ears bend when moving
-- earstiffness:			how stiff the ears are
-- earbounce: 				how bouncy the ears are

-- if you have more than one ear with the same setting, instead of givving each their own earvel variables, just call the function as normal without the earvel1, earvel2 = 
function squapi.earphysics(element, earvel1, earvel2, bendstrength, earstiffness, earbounce)
	local vel = player:getVelocity():dot((player:getLookDir().x_z):normalize())
	local yvel = player:getVelocity()[2]
	local headrot = vanilla_model.HEAD:getOriginRot()

	headrot = squapi.exorcise(headrot)

	earrot[1], earvel1 = squapi.bouncetowards(earrot[1], headrot[1], earstiffness, earbounce, earvel1)
	earrot[2], earvel2 = squapi.bouncetowards(earrot[2], headrot[2], earstiffness, earbounce, earvel2)
	earrot[3] = earrot[2]/3

	local bend = bendstrength
	if headrot[1] < -22.5 then bend = -bend end

	--y vel change
	earvel1 = earvel1 + yvel * bend
	--x vel change
	earvel1 = earvel1 + vel * bend * 1.5
	
	--applies rotations to ears
	element:setRot(earrot[1] + 45, earrot[2]/4, earrot[3])
	return earvel1, earvel2
end

--currently broken
local function toparabola(first, mid, last, X)

    local denom = (first.x - mid.x) * (first.x - last.x) * (mid.x - last.x)
    local a = (last.x * (mid.y - first.y) + mid.x * (first.y - last.y) + first.x * (last.y - mid.y)) / denom
    local b = (last.x^2 * (first.y - mid.y) + mid.x^2 * (last.y - first.y) + first.x^2 * (mid.y - last.y)) / denom
    local c = (mid.x * last.x * (mid.x - last.x) * first.y + last.x * first.x * (last.x - first.x) * mid.y + first.x * mid.x * (first.x - mid.x) * last.y) / denom

	
	
    return a * X^2 + b * X + c
end





return squapi

