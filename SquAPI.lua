
--[[--------------------------------------------------------------------------------------
███████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗██╗   ██╗     █████╗ ██████╗ ██╗
██╔════╝██╔═══██╗██║   ██║██║██╔════╝██║  ██║╚██╗ ██╔╝    ██╔══██╗██╔══██╗██║
███████╗██║   ██║██║   ██║██║███████╗███████║ ╚████╔╝     ███████║██████╔╝██║
╚════██║██║▄▄ ██║██║   ██║██║╚════██║██╔══██║  ╚██╔╝      ██╔══██║██╔═══╝ ██║
███████║╚██████╔╝╚██████╔╝██║███████║██║  ██║   ██║       ██║  ██║██║     ██║
╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝     ╚═╝                                                                         
--]]--------------------------------------------------------------------------------------ANSI Shadow

-- Author: Squishy
-- Discord tag: @mrsirsquishy

-- Version: 1.0.0 
-- Legal: ARR

-- Special Thanks to 
-- @jimmyhelp for errors and just generally helping me get things working.

-- IMPORTANT FOR NEW USERS!!! READ THIS!!!

-- Thank you for using SquAPI! Unless you're experienced and wish to actually modify the functionality
-- of this script, I wouldn't reccomend snooping around. 
-- Don't know exactly what you're doing? This site contains a guide on how to use!(also linked on github):
-- https://mrsirsquishy.notion.site/Squishy-API-Guide-3e72692e93a248b5bd88353c96d8e6c5

-- This SquAPI file does have some mini-documentation on paramaters if you need like a quick reference, but
-- do not modify, and do not copy-paste code from this file unless you are an avid scripter who knows what they are doing.


-- Don't be afraid to ask me for help, just make sure to provide as much info as possible so I or someone can help you faster.






--setup stuff
local squassets 
if pcall(require, "SquAssets") then
    squassets = require("SquAssets")
else
    error("§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")
end
local squapi = {}


-- SQUAPI CONTROL VARIABLES AND CONFIG ----------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- these variables can be changed to control certain features of squapi.


--when true it will automatically tick and update all the functions, when false it won't do that. 
--if false, you can run each objects respective tick/update functions on your own - better control. 
squapi.autoFunctionUpdates = true


-- FUNCTIONS --------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------



-- TAIL PHYSICS
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- tailSegmentList:		    the list of each individual tail segment of your tail
-- *idleXMovement:		    how much the tail should sway side to side
-- *idleYMovement:		    how much the tail should sway up and down
-- *idleXSpeed:			    how fast the tail should sway side to side 
-- *idleYSpeed:			    how fast the tail should sway up and down 
-- *bendStrength:		    how strongly the tail moves when you move
-- *velocityPush:		    this will cause the tail to bend when you move forward/backward, good if your tail is bent downward or upward. 
-- *initialMovementOffset:	this will offset the tails initial sway, this is good for when you have multiple tails and you want to desync them
-- *offsetBetweenSegments:	how much each tail segment should be offset from the previous one
-- *stiffness:			    how stiff the tail should be
-- *bounce:				    how bouncy the tail should be
-- *flyingOffset:		    when flying, riptiding, or swimming, it may look strange to have the tail stick out, so instead it will rotate to this value(so use this to flatten your tail during these movements)
-- *downLimit:			    the lowest each tail segment can rotate
-- *upLimit:			    the highest each tail segment can rotate

squapi.tails = {}
squapi.tail = {}
squapi.tail.__index = squapi.tail
function squapi.tail:new(tailSegmentList, idleXMovement, idleYMovement, idleXSpeed, idleYSpeed, bendStrength, velocityPush, initialMovementOffset, offsetBetweenSegments, stiffness, bounce, flyingOffset, downLimit, upLimit)
	local self = setmetatable({}, squapi.tail)

    -- INIT -------------------------------------------------------------------------
    --error checker
	if type(tailSegmentList) == "ModelPart" then
		tailSegmentList = {tailSegmentList}
	end
	assert(type(tailSegmentList) == "table", 
	"your tailSegmentList table seems to to be incorrect")
	
    self.berps = {}
    self.targets = {}
    self.stiffness = stiffness or .005
    self.bounce = bounce or .9
    self.downLimit = downLimit or -90
    self.upLimit = upLimit or 45
	for i = 1, #tailSegmentList do
		assert(tailSegmentList[i]:getType() == "GROUP",
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

    -- UPDATES -------------------------------------------------------------------------
	
	self.currentBodyRot = 0
	self.oldBodyRot = 0
	self.bodyRotSpeed = 0
	
    function self:tick()
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
            self.targets[i][1] = math.sin((time * self.idleXSpeed)/10 - (i)) * self.idleXMovement
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
	
	function self:render(dt, context)
        local pose = player:getPose()
        if pose ~= "SLEEPING" then
            for i, tail in ipairs(self.tailSegmentList) do
                tail:setOffsetRot(
                    self.berps[i][2]:berp(self.targets[i][2], dt),
                    self.berps[i][1]:berp(self.targets[i][1], dt),
                    0
                )
            end
        else
            
        end
	end


    table.insert(squapi.ears, self)
    return self
end


-- EAR PHYSICS
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- leftEar:		        the left ear's model path
-- *rightEar:	        the right ear's model path, if you don't have a right ear, just leave this blank or set to nil
-- *rangeMultiplier:	how far the ears should rotate with your head, reccomended 1
-- *horizontalEars:	    if you have elf-like ears(ears that stick out horizontally), set this to true
-- *bendStrength:	    how much the ears should move when you move, reccomended 2
-- *doEarFlick:	        whether or not the ears should randomly flick, reccomended true
-- *earFlickChance:	    how often the ears should flick, reccomended 400
-- *earStiffness:	    how stiff the ears should be, reccomended 0.1
-- *earBounce:	        how bouncy the ears should be, reccomended 0.8

squapi.ears = {}
squapi.ear = {}
squapi.ear.__index = squapi.ear
function squapi.ear:new(leftEar, rightEar, rangeMultiplier, horizontalEars, bendStrength, doEarFlick, earFlickChance, earStiffness, earBounce)
	local self = setmetatable({}, squapi.ear)
    
    -- INIT -------------------------------------------------------------------------
    
    assert(leftEar,
	"§4The first ear's model path is incorrect.§c")
    self.leftEar = leftEar
    self.rightEar = rightEar
    self.horizontalEars = horizontalEars
    self.rangeMultiplier = rangeMultiplier or 1
    if self.horizontalEars then self.rangeMultiplier = self.rangeMultiplier/2 end
    self.bendStrength = bendStrength or 2
    local earStiffness = earStiffness or 0.1
    local earBounce = earBounce or 0.8
    
    if doEarFlick == nil then doEarFlick = true end
    self.doEarFlick = doEarFlick
	self.earFlickChance = earFlickChance or 400

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

    -- UPDATES -------------------------------------------------------------------------

    self.eary = squassets.BERP:new(earStiffness, earBounce)
	self.earx = squassets.BERP:new(earStiffness, earBounce)
	self.earz = squassets.BERP:new(earStiffness, earBounce)
    self.targets = {0,0,0}
    self.oldpose = "STANDING"
    function self:tick()
        if self.enabled then
            local vel = math.min(math.max(-0.75, squassets.forwardVel()), 0.75)
            local yvel = math.min(math.max(-1.5, squassets.verticalVel()), 1.5)*5
            local svel = math.min(math.max(-0.5, squassets.sideVel()),0.5)
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
                local rot = 10*bend*(yvel + vel*10) + headrot[1] * self.rangeMultiplier
                local addrot = headrot[2] * self.rangeMultiplier
                self.targets[2] = rot + addrot
                self.targets[3] = -rot + addrot
            else
                self.targets[1] = headrot[1] * self.rangeMultiplier + 2*bend*(yvel + vel * 15)
                self.targets[2] = headrot[2] * self.rangeMultiplier - svel*100*self.bendStrength
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
            leftEar:setOffsetRot(0,0,0)
            rightEar:setOffsetRot(0,0,0)
        end
    end

    function self:render(dt, context)
        if self.enabled then
            self.eary:berp(self.targets[1], dt)
            self.earx:berp(self.targets[2], dt)
            self.earz:berp(self.targets[3], dt)
            
            local rot3 = self.earx.pos/4
            local rot3b = self.earz.pos/4

            if self.horizontalEars then
                local y = self.eary.pos/4
                self.leftEar:setOffsetRot(y, self.earx.pos/3, rot3)
                if self.rightEar then 
                    self.rightEar:setOffsetRot(y, self.earz.pos/3, rot3b) 
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


--CROUCH ANIMATION
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- crouch:		the animation to play when you crouch. Make sure this animation is on "hold on last frame" and override. 
-- *uncrouch:	the animation to play when you uncrouch. make sure to set to "play once" and set to override. If it's just a pose with no actual animation, than you should leave this blank or set to nil
-- *crawl:		same as crouch but for crawling
-- *uncrawl:	same as uncrouch but for crawling

function squapi.crouch(crouch, uncrouch, crawl, uncrawl) 
	
    local oldstate = "STANDING"
	function events.render(dt, context)
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



--BEWB PHYSICS
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 	    the bewb element that you want to affect(models.[modelname].path)
-- bendability(2):  how much the bewb should move when you move
-- stiff(0.05):	    how stiff the bewb should be
-- bounce(0.9):	    how bouncy the bewb should be
-- doIdle(true):    whether or not the bewb should have an idle sway(like breathing)
-- idleStrength(4): how much the bewb should sway when idle
-- idleSpeed(1):    how fast the bewb should sway when idle
-- downLimit(-10):  the lowest the bewb can rotate
-- upLimit(25):     the highest the bewb can rotate

squapi.bewbs = {}
squapi.bewb = {}
squapi.bewb.__index = squapi.bewb
function squapi.bewb:new(element, bendability, stiff, bounce, doIdle, idleStrength, idleSpeed, downLimit, upLimit)
    local self = setmetatable({}, squapi.bewb)

    -- INIT -------------------------------------------------------------------------
	assert(element,"§4Your model path for bewb is incorrect.§c")
    self.element = element
	if doIdle == nil then doIdle = true end
    self.doIdle = doIdle
	self.bendability = bendability or 2
	self.bewby = squassets.BERP:new(stiff or 0.05, bounce or 0.9, downLimit or -10, upLimit or 25 )
    self.idleStrength = idleStrength or 4
    self.idleSpeed = idleSpeed or 1
	self.target = 0

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
    

    -- UPDATE -------------------------------------------------------------------------

    self.oldpose = "STANDING"
    function self:tick()
        if self.enabled then
            local vel = squassets.forwardVel()
            local yvel = squassets.verticalVel()
            local worldtime = world.getTime()

            if self.doIdle then 
                self.target = math.sin(worldtime/8*self.idleSpeed)*self.idleStrength
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

	function self:render(dt, context)
		self.element:setOffsetRot(self.bewby:berp(self.target, dt),0,0)
	end

    table.insert(squapi.bewbs, self)
    return self
end


--RANDOM ANIMATION OBJECT
--this object will take in an animation and plays it randomly every tick by a specified amount. 
--animation:    the animation to play
--*chanceRange: an optional paramater that sets the range. 0 means every tick, larger values mean lower chances of playing every tick.
--*isBlink:     if this is for blinking set this to true so that it doesn't blink while sleeping. 

squapi.randimation = {}
squapi.randimation.__index = squapi.randimation
function squapi.randimation:new(animation, chanceRange, isBlink)
	local self = setmetatable({}, squapi.randimation)
	
    -- INIT -------------------------------------------------------------------------
    self.isBlink = isBlink
    self.animation = animation
	self.chanceRange = chanceRange or 200


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

    -- UPDATES -------------------------------------------------------------------------

	function events.tick()
		if self.enabled and (not self.isBlink or player:getPose() ~= "SLEEPING") and math.random(0, self.chanceRange) == 0 and self.animation:isStopped() then
            self.animation:play()
		end
	end

	return self
end


-- MOVING EYES
--guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element:	 		the eye element that is going to be moved, each eye is seperate.
-- *leftdistance: 	the distance from the eye to it's leftmost posistion
-- *rightdistance: 	the distance from the eye to it's rightmost posistion
-- *updistance: 	the distance from the eye to it's upmost posistion
-- *downdistance: 	the distance from the eye to it's downmost posistion
squapi.eyes = {}
squapi.eye = {}
squapi.eye.__index = squapi.eye
function squapi.eye:new(element, leftDistance, rightDistance, upDistance, downDistance, switchValues)
    local self = setmetatable({}, squapi.eye)

    -- INIT -------------------------------------------------------------------------
	assert(element,
	"§4Your eye model path is incorrect.§c")
	self.switchValues = switchValues or false
	self.left = leftDistance or .25
	self.right = rightDistance or 1.25
	self.up = upDistance or 0.5
	self.down = downDistance or 0.5
	
    self.x = 0 
    self.y = 0
    self.eyeScale = 1

    -- CONTROL -------------------------------------------------------------------------

    --For funzies if you want to change the scale of the eyes you can use this.(lerps to scale)
    function self:setEyeScale(scale)
        self.eyeScale = scale 
    end

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

    --resets position
    function self:zero()
        self.x, self.y = 0, 0
    end

    -- UPDATES -------------------------------------------------------------------------

    function self:tick()
        if self.enabled then 
            local headrot = squassets.getHeadRot()
            headrot[2] = math.max(math.min(50, headrot[2]), -50)

            --parabolic curve so that you can control the middle position of the eyes. 
            self.x = -squassets.parabolagraph(-50, -self.left, 0,0, 50, self.right, headrot[2])
            self.y = squassets.parabolagraph(-90, -self.down, 0,0, 90, self.up, headrot[1])
            
            --prevents any eye shenanigans
            self.x = math.max(math.min(self.left, self.x), -self.right)
            self.y = math.max(math.min(self.up, self.y), -self.down)
        end

    end

	function self:render(dt, context)
        local c = element:getPos()
		if self.switchValues then
			element:setPos(0,math.lerp(c[2], self.y, dt),math.lerp(c[3], -self.x, dt))
		else
			element:setPos(math.lerp(c[1], self.x, dt),math.lerp(c[2], self.y, dt),0)
		end
        local scale = math.lerp(element:getOffsetScale()[1], self.eyeScale, dt)
		element:setOffsetScale(scale, scale, scale)
	end

    table.insert(squapi.eyes, self)
    return self
end	


-- HOVER POINT ITEM
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 	        the element you are moving. Make sure that your element has
-- *springStrength(0.2):how strongly the object is pulled to it's original spot
-- *mass(5):		    how heavy the object is(heavier accelerate/deccelerate slower)
-- *resistance(1):	    how much the elements speed decays(like air resistance)
-- *rotationSpeed(0.05):how fast the element should rotate to it's normal rotation
-- *doCollisions(false):whether or not the element should collide with blocks(warning: the system is janky)

squapi.hoverPoints = {}
squapi.hoverPoint = {}
squapi.hoverPoint.__index = squapi.hoverPoint
function squapi.hoverPoint:new(element, springStrength, mass, resistance, rotationSpeed, doCollisions)
    local self = setmetatable({}, squapi.hoverPoint)

    -- INIT -------------------------------------------------------------------------
    self.element = element
    assert(self.element, 
    "§4The Hover point's model path is incorrect.§c")
    self.element:setParentType("WORLD")

    
    self.springStrength = springStrength or 0.2
    self.mass = mass or 5
    self.resistance = resistance or 1
    self.rotationSpeed = rotationSpeed or 0.05
    self.doCollisions = doCollisions

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

    -- returns to normal position
    function self:reset()
        local yaw = math.rad(player:getBodyYaw())
        local sin, cos = math.sin(yaw), math.cos(yaw)
        local offset = vec(
            cos*self.elementOffset.x - sin*self.elementOffset.z, 
            self.elementOffset.y,
            sin*self.elementOffset.x + cos*self.elementOffset.z
        )
        self.element:setPos((player:getPos() - self.elementOffset + offset)*16)
    end

    self.pos = vec(0,0,0)
    self.vel = vec(0,0,0)

    -- UPDATES -------------------------------------------------------------------------

    self.elementOffset = vec(0,0,0)
    self.init = true
    self.delay = 0
    
    function self:tick()
        if self.enabled then
            if self.init then
                self.init = false
                self.pos = player:getPos()
                self.elementOffset = self.element:partToWorldMatrix():apply()
                self.element:setPos(self.pos*16)
                self.element:setOffsetRot(0,-player:getBodyYaw(),0)
            end

            local yaw = math.rad(player:getBodyYaw())
            local sin, cos = math.sin(yaw), math.cos(yaw)
            
            --adjusts the target based on the players rotation
            local offset = vec(
                cos*self.elementOffset.x - sin*self.elementOffset.z, 
                self.elementOffset.y,
                sin*self.elementOffset.x + cos*self.elementOffset.z
            )

            local target = (player:getPos() - self.elementOffset) + offset
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

    function self:render(dt, context)
        self.element:setPos(
            math.lerp(self.element:getPos(), self.pos*16, dt/2)
        )
        self.element:setOffsetRot(0, math.lerp(self.element:getOffsetRot()[2], -player:getBodyYaw(), dt*self.rotationSpeed), 0)
    end

    table.insert(squapi.hoverPoints, self)
    return self
end




-- LEG MOVEMENT - will make an element mimic the rotation of a vanilla leg, but allows you to control the strength. Good for different length legs or legs under dresses. 
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element:             the element you want to apply the movement to
-- *strength(1):        how much it rotates(1 is default, 0.5 is half, 2 is double, etc.)
-- *isRight(false):     if this is the right leg or not
-- *keepPosition(true): if you want the element to keep it's position as well.

squapi.legs = {}
squapi.leg = {}
squapi.leg.__index = squapi.leg
function squapi.leg:new(element, strength, isRight, keepPosition)
    local self = squassets.vanillaElement:new(element, strength, keepPosition)
    
    -- INIT -------------------------------------------------------------------------
    if isRight == nil then isRight = false end
    self.isRight = isRight

    -- CONTROL -------------------------------------------------------------------------

    -- UPDATES -------------------------------------------------------------------------

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

-- ARM MOVEMENT - will make an element mimic the rotation of a vanilla arm, but allows you to control the strength. Good for different length arms. 
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element:             the element you want to apply the movement to
-- *strength(1):        how much it rotates(1 is default, 0.5 is half, 2 is double, etc.)
-- *isRight(false):     if this is the right arm or not
-- *keepPosition(true): if you want the element to keep it's position as well.

squapi.arms = {}
squapi.arm = {}
squapi.arm.__index = squapi.arm
function squapi.arm:new(element, strength, isRight, keepPosition)
    local self = squassets.vanillaElement:new(element, strength, keepPosition)
    
    -- INIT -------------------------------------------------------------------------
    if isRight == nil then isRight = false end
    self.isRight = isRight

    -- CONTROL -------------------------------------------------------------------------

    --inherits functions from squassets.vanillaElement

    -- UPDATES -------------------------------------------------------------------------

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



-- SMOOTH HEAD - Mimics a vanilla player head, but smoother and with some extra life. can also do smooth Torsos and Smooth Necks!
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 			 The head element that you wish to effect
-- *strength:            The target rotation is multiplied by this factor. For example setting to 1 will follow vanilla rotation, 0.5 is half of that, and 2 is double vanilla rotation. 
-- *tilt:                For context the smooth head applies a slight tilt to the head as it's rotated toward the side, this controls the strength of that tilt.  
-- *speed:               How fast the head will rotate toward the target rotation. For example 1 is base speed, 0.5 is half of that, and 2 is double speed. 
-- *keepOriginalHeadPos: When true(automatically true) the heads position will follow the vanilla head position. For example when crouching the head will shift down to follow. set to false to disable.

--Smooth Neck? Smooth Torso?
--This can do that too if you change what you input for these:
-- element:     Instead of a single element, input a table of head elements(imagine it like {element1, element2, etc.}). This will apply the head rotations to each of these.
-- *strength:   Instead of an single number, you can put in a table(imagine it like {strength1, strength2, etc.}). This will apply each strength to each respective element.(make sure it is the same length as your element table)
-- As a tip, you can imagine the strength as a percentage of the heads vanilla rotation. 
-- So if you have a head and a torso, you might do 0.5 for the head, and 0.5 for the torso to add up to 1(100% of the vanilla heads rotation), or maybe even 0.25 for torso, and 0.75 for head, it's up to you!

squapi.smoothHeads = {}
squapi.smoothHead = {}
squapi.smoothHead.__index = squapi.smoothHead
function squapi.smoothHead:new(element, strength, tilt, speed, keepOriginalHeadPos)
    local self = setmetatable({}, squapi.smoothHead)
	
    -- INIT -------------------------------------------------------------------------
    if type(element) == "ModelPart" then
        assert(element, "§4Your model path for smoothHead is incorrect.§c") 
		element = {element}
	end
    assert(type(element) == "table", "§4your element table seems to to be incorrect.§c")
    
    for i = 1, #element do
        assert(element[i]:getType() == "GROUP",
		"§4The head element at position "..i.." of the table is not a group. The head elements need to be groups that are nested inside one another to function properly.§c")
		assert(element[i], "§4The head segment at position "..i.." is incorrect.§c")
        element[i]:setParentType("NONE")
    end
    self.element = element

    self.strength = strength or 1 
    if type(self.strength) == "number" then
        local strengthDiv = self.strength/#element
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
    self.speed = (speed or 1)/2

    -- CONTROL -------------------------------------------------------------------------


    -- Applies an offset to the heads rotation to more easily modify it. Applies as a vector.(for multisegments it will modify the target rotation)
    function self:setOffset(xRot, yRot, zRot)
        self.offset = vec(xRot, yRot, zRot)
    end

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
        for i, v in pairs(self.element) do
            v:setPos(0, 0, 0)
            v:setOffsetRot(0, 0, 0)
            self.headRot = vec(0,0,0)
        end
    end

    
    
    -- UPDATE -------------------------------------------------------------------------
    function self:tick()
        if self.enabled then
            local vanillaHeadRot = squassets.getHeadRot()
            
            self.headRot[1] = self.headRot[1] + (vanillaHeadRot[1] - self.headRot[1])*self.speed
            self.headRot[2] = self.headRot[2] + (vanillaHeadRot[2] - self.headRot[2])*self.speed
            self.headRot[3] = self.headRot[2]*self.tilt
        end
    end

	function self:render(dt, context) 
        if self.enabled then
            dt = dt/5
            for i, v in pairs(self.element) do
                local c = self.element[i]:getOffsetRot()
                local target = (self.headRot*self.strength[i])-self.offset/#self.element
                self.element[i]:setOffsetRot(math.lerp(c[1], target[1], dt), math.lerp(c[2], target[2], dt), math.lerp(c[3], target[3], dt))

                -- Better Combat SquAPI Compatibility created by @jimmyhelp and @foxy2526 on Discord
                if renderer:isFirstPerson() and context == "RENDER" then
                    self.element[i]:setVisible(false)
                else
                    self.element[i]:setVisible(true)
                end
            end
            
            if self.keepOriginalHeadPos then 
                self.element[#self.element]:setPos(-vanilla_model.HEAD:getOriginPos()) 
            end
        end
	end

    table.insert(squapi.smoothHeads, self)
    return self
end






--BOUNCE WALK
-- guide:(note if it has a * that means you can leave it blank/nil to use reccomended settings)
-- model:			    the path to your model element. Most cases, if you're model is named "model", than it'd be models.model (replace model with the name of your model) 
-- *bounceMultipler:    normally 1, this multiples how much the bounce occurs. values greater than 1 will increase bounce, and values less than 1 will decrease bounce.

squapi.bounceWalks = {}
squapi.bounceWalk = {}
squapi.bounceWalk.__index = squapi.bounceWalk
function squapi.bounceWalk:new(model, bounceMultiplier)
    local self = setmetatable({}, squapi.bounceWalk)
    -- INIT -------------------------------------------------------------------------
    assert(model, "Your model path is incorrect for bounceWalk")
	self.bounceMultiplier = bounceMultiplier or 1
    self.target = 0
	
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

    -- UPDATES -------------------------------------------------------------------------
    
    function self:render(dt, context)
        local pose = player:getPose()
        if self.enabled and (pose == "STANDING" or pose == "CROUCHING") then
            
            local leftlegrot = vanilla_model.LEFT_LEG:getOriginRot()[1]
            local bounce = self.bounceMultiplier
            if pose == "CROUCHING" then
                bounce = bounce/2
            end
            self.target = math.abs(leftlegrot)/40*bounce
            
        else
            self.target = 0
        end 
		model:setPos(0, math.lerp(model:getPos()[2], self.target, dt), 0)
	end

    table.insert(squapi.bounceWalks, self)
    return self
end




--TAUR PHYSICS
-- guide: (note if it has a * that means you can leave it blank)
-- taurBody:    the group of the body that contains all parts of the actual centaur part of the body, pivot should be placed near the connection between body and taurs body
-- *frontLegs: 	the group that contains both front legs
-- *backLegs: 	the group that contains both back legs

squapi.taurs = {}
squapi.taur = {}
squapi.taur.__index = squapi.taur
function squapi.taur:new(taurBody, frontLegs, backLegs)
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
    function self:toggle()
		self.enabled = not self.enabled
	end
    function self:disable()
        self.enabled = false
    end
    function self:enable()
        self.enabled = true
    end


    -- UPDATES -------------------------------------------------------------------------
	
    function self:tick()
        if self.enabled then
            self.target = math.min(math.max(-30, squassets.verticalVel() * 40), 45)
        end
    end

    function self:render(dt, context)
		if self.enabled then 
            self.taur:berp(self.target, dt/2) 
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
                    self.backLegs:setRot(self.taur.pos*3, 0, 0)
                end
                if self.frontLegs then
                    self.frontLegs:setRot(-self.taur.pos*3, 0, 0)
                end
            end
        end
	end

    table.insert(squapi.taurs, self)
    return self
end



-- CUSTOM FIRST PERSON HAND
--!!Make sure the setting for modifying first person hands is enabled in the Figura settings for this to work properly!!
-- guide:(note if it has a * that means you can leave it blank/nil to use reccomended settings)
-- element:	the actual hand element to change
-- *x: 		        the x change
-- *y: 		        the y change
-- *z: 		        the z change
-- *scale:          this will multiply the size of the element by this size
-- *onlyVisibleInFP:if true, this will make the element invisible when not in first person

squapi.FPHands = {}
squapi.FPHand = {}
squapi.FPHand.__index = squapi.FPHand
function squapi.FPHand:new(element, x, y, z, scale, onlyVisibleInFP)
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
    
    function self:updatePos(x, y, z)
        self.x = x
        self.y = y
        self.z = z
    end

    -- UPDATES -------------------------------------------------------------------------
    function self:render(dt, context)
        if context == "FIRST_PERSON" then 
            if self.onlyVisibleInFP then
                self.element:setVisible(true)
            end 
			self.element:setPos(self.x, self.y, self.z)
			self.element:setScale(self.scale,self.scale,self.scale)
		else
            if self.onlyVisibleInFP then
                self.element:setVisible(false)
            end 
            self.element:setPos(0,0,0)
        end
        
    end
    
    table.insert(squapi.FPHands, self)
    return self
end

-- Easy-use Animated Texture.
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 		the part of your model who's texture will be aniamted
-- numberOfFrames: 	the number of frames
-- framePercent:	what percent width/height the uv takes up of the whole texture. for example: if there is a 100x100 texture, and the uv is 20x20, this will be .20
-- *slowFactor: 	increase this to slow down the animation. 
-- *vertical:		set to true if you'd like the animation frames to go down instead of right.
function squapi.animateTexture(element, numberOfFrames, framePercent, slowFactor, vertical)
	assert(element,
	"§4Your model path for animateTexture is incorrect.§c")
	vertical = vertical or false
	slowFactor = slowFactor or 1
	function events.tick()
		local time = world.getTime()
		local frameshift = math.floor(time/slowFactor)%numberOfFrames*framePercent
		if vertical then element:setUV(0, frameshift) else element:setUV(frameshift, 0) end
	end
end



-- UPDATES ALL SQUAPI FEATURES --------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

if squapi.autoFunctionUpdates then

    function events.tick()
        for i, v in pairs(squapi.smoothHeads) do
            v:tick()
        end
        for i, v in pairs(squapi.eyes) do
            v:tick()
        end
        for i, v in pairs(squapi.bewbs) do
            v:tick()
        end
        for i, v in pairs(squapi.hoverPoints) do
            v:tick()
        end
        for i, v in pairs(squapi.ears) do
            v:tick()
        end
        for i, v in pairs(squapi.tails) do
            v:tick()
        end
        for i, v in pairs(squapi.taurs) do
            v:tick()
        end
    end

    function events.render(dt, context)
        for i, v in pairs(squapi.smoothHeads) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.FPHands) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.bounceWalks) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.legs) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.arms) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.eyes) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.bewbs) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.hoverPoints) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.ears) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.tails) do
            v:render(dt, context)
        end
        for i, v in pairs(squapi.taurs) do
            v:render(dt, context)
        end
    end

end







return squapi