
--███████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗██╗   ██╗███████╗     █████╗ ██████╗ ██╗
--██╔════╝██╔═══██╗██║   ██║██║██╔════╝██║  ██║╚██╗ ██╔╝██╔════╝    ██╔══██╗██╔══██╗██║
--███████╗██║   ██║██║   ██║██║███████╗███████║ ╚████╔╝ ███████╗    ███████║██████╔╝██║
--╚════██║██║▄▄ ██║██║   ██║██║╚════██║██╔══██║  ╚██╔╝  ╚════██║    ██╔══██║██╔═══╝ ██║
--███████║╚██████╔╝╚██████╔╝██║███████║██║  ██║   ██║   ███████║    ██║  ██║██║     ██║
--╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝     ╚═╝
----------------------------------------------------------------------------------------

-- Author: Squishy
-- Discord tag: mrsirsquishy

-- Version: 0.2.0
-- Legal: Do not Redistribute without explicit permission.

-- IMPORTANT FOR NEW USERS!!! READ THIS!!!

-- Thank you for using SquAPI! Unless you're experienced and wish to actually modify the functionality
-- of this script, I wouldn't reccomend snooping around. 
-- Don't know exactly what you're doing? This site should explain everything!(also linked on github):
-- https://mrsirsquishy.notion.site/Squishy-API-Guide-3e72692e93a248b5bd88353c96d8e6c5

-- This file does have some mini-documentation on paramaters if you need like a quick reference, but
-- do not modify, and do not copy-paste code from this file unless you are an avid scripter who knows what they are doing.


-- Don't be afraid to ask me for help, be afraid of not giving me enough info to help




local squapi = {}



-- Control Variables
-- these variables can be changed within your script to control certain features of squapi
-- to do so, call squapi.[variable name] = [what you want]
-- within your script(do not modify these within squapi itself)

--set to false to disable blinking, set to true to enable blinking
squapi.doBlink = true

--controls the scale of each eye. good for emotes.
squapi.eyeScale = 1

--how much the tails wag. increase this value to make the tails waggier. good for emotes.
squapi.wagStrength = 1

--detects if the bounce function is enabled, doesn't typically need to be modified
squapi.doBounce = false

--altering this value will add to the head rot if smooth Head is enabled
squapi.smoothHeadOffset = vec(0,0,0)

--enable/disable floating point
squapi.floatPointEnabled = true

--the smoothTorso function will enable this automatically, this will basically cancel out the heads movement based on the torsos movement so your head doesn't bend too far.
squapi.cancelHeadMovement = false
squapi.torsoOffset = vec(0,0,0)

-- WALKING AND SPRINTING ANIMATIONS

function squapi.walk(walkanim, runanim)
	
	runanim = runanim or nil

	walksmooth = squapi.bounceObject:new()
	runsmooth = squapi.bounceObject:new()

	walkanim:play()
	if runanim ~= nil then runanim:play() end

	function events.render(delta, context)
		
		local vel = squapi.getForwardVel()
		if vel > 0.3 then vel = 0.3 end

		walkanim:setBlend(walksmooth:doBounce(vel*4.633, .001, .2))
		walkanim:setSpeed(walksmooth.pos)
		
		if runanim ~= nil then
			
			if player:isSprinting() then
				walkanim:setBlend(0)
				
				local target = vel*3.57
				--prevents wierd issue when looking up
				if target == 0 then
					target = 1
				end

				if runsmooth.pos < 0 then
					runsmooth.pos = runsmooth.pos * -4
				end
				runanim:setBlend(runsmooth:doBounce(target, .001, .2))
				runanim:setSpeed(runsmooth.pos)

			else
				runanim:setBlend(runsmooth:doBounce(0, .001, .2))
				runanim:setSpeed(runsmooth.pos)
			end
		end

	end
end


--FLOATING POINT ITEM
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 	the element you are moving. Make sure that your element has
-- *xoffset: 	where it is positioned from 0 on the x axis
-- *yoffset: 	where it is positioned from 0 on the y axis
-- *zoffset: 	where it is positioned from 0 on the z axis
-- *ymin:	 	how far down the "floor" is; this helps prevent it from clipping into the ground too much(may still clip a bit)
-- *maxradius	this will limit how far away the object can go. setting to "nil" means no limit

function squapi.floatPoint(element, xoffset, yoffset, zoffset, stiffness, bouncy, ymin, maxradius)
	element:setParentType("WORLD")
	local point = {
		squapi.bounceObject:new(), 
		squapi.bounceObject:new(), 
		squapi.bounceObject:new(), 
		squapi.bounceObject:new()
	}
	local stiff = stiffness or .02
	local bounce = bouncy or .0005


	local rotstiff = .0005
	local rotbounce =  .03

	local ymin = ymin or 30
	local maxradius = maxradius or nil
	local init = true

	local x = xoffset or 0
	local y = yoffset or 0
	local z = zoffset or 0

	function events.render(delta, context)
		if init then
			point[1].pos = player:getPos()[1]*16 + x
			point[2].pos = player:getPos()[2]*16 + y
			point[3].pos = player:getPos()[3]*16 + z
			point[4].pos = -player:getBodyYaw()-180

			init = false
		end
		
		local targetx = player:getPos()[1]*16
		local targety = player:getPos()[2]*16
		local targetz = player:getPos()[3]*16
		local targetrot = -player:getBodyYaw()-180
		
		--avoids going to low/getting to far based on radius and miny
		stiff = stiffness or .02
		bounce = bouncy or .0005
		if point[2].pos-player:getPos()[2]*16 < -ymin then
			stiff = 0.035
			bounce = .01
		elseif maxradius ~= nil then
			if  
				point[1].pos-player:getPos()[1]*16 < -maxradius 
				or point[1].pos-player:getPos()[1]*16 > maxradius  
				or point[2].pos-player:getPos()[2]*16 < -maxradius 
				or point[2].pos-player:getPos()[2]*16 > maxradius 
				or point[3].pos-player:getPos()[3]*16 < -maxradius 
				or point[3].pos-player:getPos()[3]*16 > maxradius 
				then
					
					stiff = stiff*0.57
					bounce = bounce * 400		
			end
		end
		
		--local truepos = element:getPos() - player:getPos()*16
		if squapi.floatPointEnabled then
			element:setPivot(-x,-y,-z)
			element:setPos(
				point[1]:doBounce(targetx, bounce, stiff) + x,
				point[2]:doBounce(targety, bounce, stiff) + y, 
				point[3]:doBounce(targetz, bounce, stiff) + z
			)
			element:setRot(0, point[4]:doBounce(targetrot, rotstiff, rotbounce), 0)
		end
	end
end



--BOUNCE WALK
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- model:			the path to your model element. Most cases, if you're model is named "model", than it'd be models.model (replace model with the name of your model) 
-- *bounceMultipler:normally 1, this multiples how much the bounce occurs. values greater than 1 will increase bounce, and values less than 1 will decrease bounce.
function squapi.bouncewalk(model, bounceMultipler)
	squapi.doBounce = true
	bouncemultipler = bounceMultipler or 1
	function events.render(delta, context)
		if player:isOnGround() then
			local pose = player:getPose()
			local bounce = bouncemultipler
			if pose == "CROUCHING" then
				bounce = bounce/2
			end
			leftlegrot = vanilla_model.LEFT_LEG:getOriginRot()[1]
			model:setPos(0, math.abs(leftlegrot)/40*bounce, 0)
		end
	end
end

--CROUCH ANIMATION
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- crouch:		the animation to play when you crouch. Make sure this animation is on "hold on last frame" and override. 
-- *uncrouch:	the animation to play when you uncrouch. make sure to set to "play once" and set to override. If it's just a pose with no actual animation, than you should leave this blank or set to nil
-- *crawl:		same as crouch but for crawling
-- *uncrawl:	same as uncrouch but for crawling
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

-- SMOOTH TORSO MOVEMENT
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element:				the torso element that you wish to effect. Make sure this group/bone contains all elements attached to the body.
-- *strengthmultiplier:	normally .4; this controls how strongly the torso moves
function squapi.smoothTorso(element, strengthMultiplier, tilt)
	strengthmultiplier = strengthMultiplier or .5
	tilt = tilt or 0.4
	squapi.cancelHeadMovement = true
	local mainbodyrot = vec(0, 0, 0)

	function events.render(delta, context)
		local headrot = ((vanilla_model.HEAD:getOriginRot()+180)%360-180)*strengthmultiplier
		mainbodyrot[1] = mainbodyrot[1] + (headrot[1] - mainbodyrot[1])/12
		mainbodyrot[2] = mainbodyrot[2] + (headrot[2] - mainbodyrot[2])/12
		mainbodyrot[3] = mainbodyrot[2]*tilt

		element:setOffsetRot(mainbodyrot)
		squapi.torsoOffset = mainbodyrot

		-- Better Combat SquAPI Compatibility created by @jimmyhelp and @foxy2526 on Discord
		if renderer:isFirstPerson() and context == "RENDER" then
			element:setVisible(false)
			-- Set path to head model
		else
			element:setVisible(true)
			-- Set path to head model
		end
	end
end

-- SMOOTH HEAD
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 			the head element that you wish to effect
-- *keeporiginalheadpos: when true(automatically true) the heads position will change like normally, set to false to disable.
-- IMPORTANT: for this to work you need to name your head element something other than "Head" - the name "Head" will make it follow vanilla rotations which we don't want, so it is reccomended to rename it to something like "head" instead)
function squapi.smoothHead(element, tilt, strength, keeporiginalheadpos)
	strength = strength or 1
	tilt = tilt or 1/10
	if keeporiginalheadpos == nil then keeporiginalheadpos = true end
	local mainheadrot = vec(0, 0, 0)
	local offset = vec(0,0,0)
	function events.render(delta, context)
		local headrot = (vanilla_model.HEAD:getOriginRot()+180 + squapi.smoothHeadOffset)%360-180
		
		if squapi.cancelHeadMovement then
			offset = squapi.torsoOffset
		end
		mainheadrot[1] = mainheadrot[1] + (headrot[1] - mainheadrot[1])/12
		mainheadrot[2] = mainheadrot[2] + (headrot[2] - mainheadrot[2])/12
		mainheadrot[3] = mainheadrot[2]*tilt
		mainheadrot = mainheadrot
	

		element:setOffsetRot((mainheadrot-offset)*strength)
		if keeporiginalheadpos then 
			element:setPos(-vanilla_model.HEAD:getOriginPos()) 
		end
		
		-- Better Combat SquAPI Compatibility created by @jimmyhelp and @foxy2526 on Discord
		if renderer:isFirstPerson() and context == "RENDER" then
			element:setVisible(false)
			-- Set path to head model
		else
			element:setVisible(true)
			-- Set path to head model
		end


	end
end

-- SMOOTH HEAD WITH NECK
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element:	 			the head element
-- element2: 			the neck element
-- *keeporiginalheadpos: when true(automatically true) the heads position will change like normally, set to false to disable.
function squapi.smoothHeadNeck(element, element2, tilt, strength, keeporiginalheadpos)
	strength = strength or 1
	tilt = tilt or 2.5
	tilt = tilt/5
	if keeporiginalheadpos == nil then keeporiginalheadpos = true end
	local mainheadrot = vec(0, 0, 0)
	function events.render(delta, context)
		local headrot = (vanilla_model.HEAD:getOriginRot()+180 + squapi.smoothHeadOffset)%360-180
		mainheadrot[1] = mainheadrot[1] + (headrot[1] - mainheadrot[1])/12
		mainheadrot[2] = mainheadrot[2] + (headrot[2] - mainheadrot[2])/12
		mainheadrot[3] = mainheadrot[2]*tilt
		mainheadrot = mainheadrot
		element:setOffsetRot(mainheadrot * 0.6 * strength)
		element2:setOffsetRot(mainheadrot * 0.4 * strength)
		if keeporiginalheadpos then 
			element:setPos(-vanilla_model.HEAD:getOriginPos()) 
		end
		
		-- Better Combat SquAPI Compatibility created by @jimmyhelp and @foxy2526 on Discord
		if renderer:isFirstPerson() and context == "RENDER" then
			element:setVisible(false)
			element2:setVisible(false)
		else
			element:setVisible(true)
			element2:setVisible(true)
		end


	end
end



-- MOVING EYES
--guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element:	 		the eye element that is going to be moved, each eye is seperate.
-- *leftdistance: 	the distance from the eye to it's leftmost posistion
-- *rightdistance: 	the distance from the eye to it's rightmost posistion
-- *updistance: 	the distance from the eye to it's upmost posistion
-- *downdistance: 	the distance from the eye to it's downmost posistion

function squapi.eye(element, leftdistance, rightdistance, updistance, downdistance, switchvalues)
	local switchvalues = switchvalues or false
	local left = leftdistance or .25
	local right = rightdistance or 1.25
	local up = updistance or 0.5
	local down = downdistance or 0.5
	
	function events.render(delta, context)
		local headrot = (vanilla_model.HEAD:getOriginRot()+180)%360-180
		if headrot[2] > 50 then headrot[2] = 50 end
		if headrot[2] < -50 then headrot[2] = -50 end
		local x = -squapi.parabolagraph(-50, -left, 0,0, 50, right, headrot[2])
		local y = squapi.parabolagraph(-90, -down, 0,0, 90, up, headrot[1])
		
		--prevents any eye shenanigans
		if x > left then x = left end
		if x < -right then x = -right end
		if y > up then y = up end
		if y < -down then y = down end

		if switchvalues then
			element:setPos(0,y,-x)
		else
			element:setPos(x,y,0)
		end
		element:setOffsetScale(squapi.eyeScale,squapi.eyeScale,squapi.eyeScale)
	end
end	


--BLINK
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- animation: 			the blink animation to play
-- *chancemultipler:	higher values make blinks less likely to happen, lower values make them more common.
function squapi.blink(animation, chancemultipler)
	local blinkchancemultipler = chancemultipler or 1
	function events.tick()
		if math.random(0, 200 * blinkchancemultipler) == 1 and animation:isStopped() and squapi.doBlink then
			animation:play()
		end
	end	
end


--TAIL PHYSICS!!
--guide:(note if it has a * that means you can leave it blank to use reccomended settings)
--tailsegs:				this is an ARRAY of each element/segment in your tail. for example: local array = {element, element2, etc.} Your array can have only one element if you have only one tail part.
--*intensity:			how intensly the tail moves when you rotate/move. Reccomend 2
--*tailintesnityY:		how much the tail moves up and down
--*tailintensityX:		how much the tail moves side to side
--*tailYSpeed:			how fast the tail moves up and down
--*tailXSpeed:			how fast the tail moves side to side
--*tailVelBend:			how much the tail bends when you move forward/back. positive values bend up, negative values bend down.
--*initialTailOffset:	how much to offset the tails animation initially. If you have multiple tails I reccomend using this to slightly offset each. so tail 1 offset by 0, tail 2 offset by 0.5, etc. set 0 to ignore
--*segOffsetMultipler:	how much each segment is offset from the last. 1 is reccomended.
--*tailStiff:			how stiff the tails are
--*tailBounce:			how bouncy the tails are
--*tailFlyOffset		what rotation the tail should have when flying(elytra or riptide) normally 0. Example would be if your tail sticks out when flying, set to 75 to rotate the tail 75 deg down.
--*downLimit:			the max distance the tail will bend down
--*upLimit:				the max distance the tail will bend up

--reccomended function:
--squapi.tails(tailsegs, 2, 15, 5, 2, 1.2, 0, 0, 1, .0005, .06, 0, nil, nil)
function squapi.tails(tailsegs, intensity, tailintensityY, tailintensityX, tailYSpeed, tailXSpeed, tailVelBend, initialTailOffset, segOffsetMultipler, tailStiff, tailBounce, tailFlyOffset, downLimit, upLimit)
	local intensity = intensity or 2
	local tailintensity = tailintensityY or 15
	local tailintensityx = tailintensityX or 5
	local tailyspeed = tailYSpeed or 2
	local tailxspeed = tailXSpeed or 1.2
	local tailvelbend = tailVelBend or 0
	local initialTailOffset = initialTailOffset or 0
	local tailstiff = tailStiff or .005
	local tailbounce = tailBounce or .05
	local tailflyoffset = tailFlyOffset or 0
	local tailrot, tailvel, tailrotx, tailvelx = {}, {}, {}, {}
	local segoffsetmultipler = segOffsetMultipler or 1
	local downLimit = downLimit or 10
	local upLimit = upLimit or 40

	--error checker
	if type(tailsegs) == "ModelPart" then
		tailsegs = {tailsegs}
	end
	assert(type(tailsegs) == "table", "your tailsegs table seems to to be incorrect")
	
	for i = 1, #tailsegs do
        tailrot[i], tailvel[i], tailrotx[i], tailvelx[i] = 0, 0, 0, 0
    end
	
	local currentbodyrot = 0
	local oldbodyrot = 0
	local bodyrotspeed = 0
	function events.tick()
		oldbodyrot = currentbodyrot
		currentbodyrot = player:getBodyYaw()
		bodyrotspeed = currentbodyrot-oldbodyrot
		if bodyrotspeed > 20 then bodyrotspeed = 20
		elseif	bodyrotspeed < -20 then bodyrotspeed = -20 end
	end
	
	function events.render(delta, context)
		local time = world.getTime() + delta
		local vel = squapi.getForwardVel()
		local yvel = squapi.yvel()
		--local svel = squapi.getSideVelocity()
		local tailintensity = tailintensity/(math.abs((yvel*30))-vel*30 + 1)
		local pose = player:getPose()
		for i, tail in ipairs(tailsegs) do
			local tailtargety = math.sin((time * tailxspeed)/10 - (i * segoffsetmultipler) + initialTailOffset) * tailintensity
			local tailtargetx = math.sin((time * tailyspeed * (squapi.wagStrength))/10 - (i)) * tailintensityx * squapi.wagStrength

			tailtargetx = tailtargetx + bodyrotspeed*intensity*0.5-- + svel*intensity*40
			tailtargety = tailtargety + yvel * 20 * intensity - vel*intensity*50*tailvelbend
			
			

			if downLimit ~= nil then
				if tailtargety > downLimit then tailtargety = downLimit end
			end
			if upLimit ~= nil then
				if tailtargety < -upLimit then tailtargety = -upLimit end
			end

			if i == 1 then
				if pose == "FALL_FLYING" or pose == "SWIMMING" or player:riptideSpinning() then
					tailtargety = tailflyoffset
				end	
			end

			tailrot[i], tailvel[i] = squapi.bouncetowards(tailrot[i], tailtargety, tailvel[i], tailstiff, tailbounce)
			tailrotx[i], tailvelx[i] = squapi.bouncetowards(tailrotx[i], tailtargetx, tailvelx[i], tailstiff, tailbounce)
			
			if pose ~= "SLEEPING" then 
				tail:setOffsetRot(tailrot[i], tailrotx[i], 0)
			end
		end
	end
	
end



--BOUNCY EARS
--guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 		the ear element that you want to affect(models.[modelname].path)
-- *element2: 		the second element you'd like to use(second ear), set to nil or leave empty to ignore
-- *doearflick:		reccomended true. This adds the random chance for the ears to do a "flick" animation, set to false to disable.
-- *earflickchance:	how rare a flick should be. high values mean less liklihood, low values mean high liklihood.(200 reccomended)
-- *rangemultiplier:at normal state of 1 the ears rotate from -90 to 90, this range will be multiplied by this, so a value of 0.5 would half the range
-- *horizontalEars: setting this to true will change the motion of the ears to be sideways, like elf ears.
-- *bendstrength: 	how strong the ears bend when you move(jump, fall, run, etc.)
-- *earstiffness: 	how stiff the ears movement is(0-1)
-- *earbounce: 		how bouncy the ears are(0-1)

function squapi.ear(element, element2, doearflick, earflickchance, rangemultiplier, horizontalEars, bendstrength, earstiffness, earbounce)
	if doearflick == nil then doearflick = true end
	local earflickchance = earflickchance or 400
	local element2 = element2 or nil
	local bendstrength = bendstrength or 2
	local earstiffness = earstiffness or 0.025
	local earbounce = earbounce or 0.1
	local horizontalEars = horizontalEars or false
	local rangemultiplier = rangemultiplier or 1
	
	local eary = squapi.bounceObject:new()
	local earx = squapi.bounceObject:new()
	local earx2 = squapi.bounceObject:new()
	local leftlegrot = 0
	local oldpose = "STANDING"
	function events.render(delta, context)
		local leftlegrot
		if squapi.doBounce then
			leftlegrot = vanilla_model.LEFT_LEG:getOriginRot()[1]
		else
			leftlegrot = 0
		end
		local vel = squapi.getForwardVel()
		local yvel = squapi.yvel()
		local svel = squapi.getSideVelocity()
		local headrot = (vanilla_model.HEAD:getOriginRot()+180)%360-180
		
		local bend = bendstrength
		if headrot[1] < -22.5 then bend = -bend end
		
		--moves when player crouches
		local pose = player:getPose()
		if pose == "CROUCHING" and oldpose == "STANDING" then
			eary.vel = eary.vel + 3 * bendstrength
		elseif pose == "STANDING" and oldpose == "CROUCHING" then
			eary.vel = eary.vel - 3 * bendstrength
		end
		oldpose = pose

		--y vel change
		if horizontalEars then
			earx.vel = earx.vel + yvel * bend
			--x vel change
			earx.vel = earx.vel + vel * bend * 1.5 *10

			earx2.vel = earx2.vel - yvel * bend
			--x vel change
			earx2.vel = earx2.vel - vel * bend * 1.5 *10
		else
			eary.vel = eary.vel + yvel * bend
			--x vel change
			eary.vel = eary.vel + vel * bend * 1.5 *10
		end

		if doearflick then
			if math.random(0, earflickchance) == 1 then
				if math.random(0, 1) == 1 then
					earx.vel = earx.vel + 50
				else
					earx2.vel = earx2.vel - 50
				end
			end
		end
		
		local rot1 = eary:doBounce(headrot[1] * rangemultiplier - math.abs(leftlegrot)/8*bendstrength, earstiffness, earbounce)
		local rot2 = earx:doBounce(headrot[2] * rangemultiplier - svel*150*bendstrength, earstiffness, earbounce)
		local rot2b = earx2:doBounce(headrot[2] * rangemultiplier - svel*150*bendstrength, earstiffness, earbounce)
		
		--prevents chaos ears
		if rot2 > 90 then rot2 = 90 end
		if rot2 < -90 then rot2 = -90 end
		if rot1 > 90 then rot1 = 90 end
		if rot1 < -90 then rot1 = -90 end
		if rot2b > 90 then rot2b = 90 end
		if rot2b < -90 then rot2b = -90 end

		local rot3 = rot2/4
		local rot3b = rot2b/4
		if horizontalEars then
			element:setOffsetRot(rot1/4, rot2/3, rot3)
			if element2 ~= nil then 
				element2:setOffsetRot(rot1/4, rot2b/3, rot3b) 
			end
		else
			element:setOffsetRot(rot1, rot2/4, rot3)
			if element2 ~= nil then 
				element2:setOffsetRot(rot1, rot2b/4, rot3b) 
			end
		end
		
	end
end

--BOUNCY BEWB PHYSICS
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 	 the bewb element that you want to affect(models.[modelname].path)
-- *doidle: 	 the bewb will slowly move idly in a sort of breathing animation, normally true, set this to false to disable that.
-- *bendability: how much it should bend when you move. reccomended 2, if you're bored set to 10
-- *stiff: 		 how stiff they are(0-1)
-- *bounce: 	 how bouncy they are(0-1)
function squapi.bewb(element, doidle, bendability, stiff, bounce)
	if doidle == nil then doidle = true end
	local stiff = stiff or 0.025
	local bounce = bounce or 0.06
	local bendability = bendability or 2
	local bewby = squapi.bounceObject:new()
	local target = 0

	local oldpose = "STANDING"
	function events.Render(delta, context)
		local vel = squapi.getForwardVel()
		local yvel = squapi.yvel()
		local worldtime = world.getTime() + delta

		if doidle then target = math.sin(worldtime/8)*2*bendability end

		--physics when crouching/uncrouching
		local pose = player:getPose()
		if pose == "CROUCHING" and oldpose == "STANDING" then
			bewby.vel = bewby.vel + bendability
		elseif pose == "STANDING" and oldpose == "CROUCHING" then
			bewby.vel = bewby.vel - bendability
		end
		oldpose = pose

		--physics when moving
		if bewby.pos < 25 and bewby.pos > -30 then
			bewby.vel = bewby.vel - yvel/2 * bendability
			bewby.vel = bewby.vel - vel/3 * bendability
		end

		element:setOffsetRot(bewby:doBounce(target, stiff, bounce),0,0)
	end
end



-- Easy-use Animated Texture.
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element: 		the part of your model who's texture will be aniamted
-- numberofframes: 	the number of frames
-- framepercent:	what percent width/height the uv takes up of the whole texture. for example: if there is a 100x100 texture, and the uv is 20x20, this will be .20
-- *slowfactor: 	increase this to slow down the animation. 
-- *vertical:		set to true if you'd like the animation frames to go down instead of right.
function squapi.animateTexture(element, numberofframes, framepercent, slowfactor, vertical)
	vertical = vertical or false
	frameslowfactor = slowfactor or 1
	function events.tick()
		local time = world.getTime()
		local frameshift = math.floor(time/frameslowfactor)%numberofframes*framepercent
		if vertical then element:setUV(0, frameshift) else element:setUV(frameshift, 0) end
	end
end

-- Change position of first person hand
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- element:	the actual hand element to change
-- *x: 							the x change
-- *y: 							the y change
-- *z: 							the z change
-- *scale:						the scale of the hand in first person
-- *onlyVisibleInFirstPerson:	if this is true, the element will ONLY be visible in first person
function squapi.setFirstPersonHandPos(element, x, y, z, scale, onlyVisibleInFirstPerson)
	onlyVisibleInFirstPerson = onlyVisibleInFirstPerson or false
	x = x or 0
	y = y or 0
	z = z or 0
	scalex = scale or 1
	function events.Render(delta, context)
		if context == "FIRST_PERSON" then 
			if onlyVisibleInFirstPerson then element:setVisible(true) end
			element:setPos(x, y, z)
			element:setScale(scale,scale,scale)
		else 
			if onlyVisibleInFirstPerson then element:setVisible(false) end
			element:setPos(0, 0, 0)
			element:setScale(1,1,1)
		end
	end
end



--TAUR PHYSICS
-- guide:
-- taurbody: the group of the body that contains all parts of the actual centaur part of the body, pivot should be placed near the connection between body and centaur body
-- frontlegs: 	the group that contains both front legs
-- backlegs: 	the group that contains both back legs
function squapi.taurPhysics(taurbody, frontlegs, backlegs)
	squapi.cent = squapi.bounceObject:new()
	
	function events.render(delta, context)
		local yvel = squapi.yvel()
		local pose = player:getPose()
		
		if pose == "FALL_FLYING" or pose == "SWIMMING" or (player:isClimbing() and not player:isOnGround()) or player:riptideSpinning() then
			
			taurbody:setRot(80, 0, 0)
			backlegs:setRot(-50, 0, 0)
			frontlegs:setRot(-50, 0, 0)
		else	
			taurbody:setRot(squapi.cent.pos, 0, 0)
			backlegs:setRot(squapi.cent.pos*1.5, 0, 0)
			frontlegs:setRot(-squapi.cent.pos*3.5, 0, 0)
		end
		local target = yvel * 40
		if target < -30 then target = -30 end
		squapi.cent:doBounce(target, 0.01, .2)
	end
end

-- USEFUL CALLS ------------------------------------------------------------------------------------------

-- returns how fast the player moves forward, negative means backward
function squapi.getForwardVel()
	return player:getVelocity():dot((player:getLookDir().x_z):normalize())
end

-- returns y velocity
function squapi.yvel()
	return player:getVelocity()[2]
end

-- returns how fast player moves sideways, negative means left
-- Courtesy of @auriafoxgirl on discord
function squapi.getSideVelocity()
	return (player:getVelocity() * matrices.rotation3(0, player:getRot().y, 0)).x
end


--functions that are made for use through this code, or personal use. Not meant to be used outside but if you know what you're doing go ahead. 
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

--[[
function squapi.getSideVelocity()
	local vel = player:getVelocity()
	local look = player:getLookDir().z_x
	local totalvel = math.sqrt(vel[1]^2 + vel[3]^2)
	
	--angle of velocity relative to world
	local velangle = (-math.deg(math.atan2(vel[3], vel[1])) + 360) % 360
	--angle of player relative to world
	local angle = (math.deg(math.atan2(look[3], look[1])) + 630) % 360
	--angle of velocity relative to players rotation
	local angledif = ((angle - velangle + 180) % 360) - 180

	local sidevel = -math.sin(math.rad(angledif))*totalvel
	
	return sidevel
end
--]]


-- Linear graph stuff
function squapi.lineargraph(x1, y1, x2, y2, t)
	local slope = (y2-y1)/(x2-x1)
	local inter = y2 - slope*x2
	return slope*t + inter
end

--Parabolic graph stuff
function squapi.parabolagraph(x1, y1, x2, y2, x3, y3, t)
    local denom = (x1 - x2) * (x1 - x3) * (x2 - x3)
    
	local a = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / denom
    local b = (x3^2 * (y1 - y2) + x2^2 * (y3 - y1) + x1^2 * (y2 - y3)) / denom
    local c = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / denom

    -- returns y based on t
    return a * t^2 + b * t + c
end

--smooth bouncy stuff
local bounceID = 0
squapi.bounceObject = {}
squapi.bounceObject.__index = squapi.bounceObject
function squapi.bounceObject:new()
	local o = {
		vel = 0,
		pos = 0
	}
	bounceID = bounceID + 1
	setmetatable(o, squapi.bounceObject)
	return o
end	
function squapi.bounceObject:doBounce(target, stiff, bounce)
	local target = target or 2
	local dif = target - self.pos
	self.vel = self.vel + ((dif - self.vel * stiff) * stiff)
	self.pos = (self.pos + self.vel) + (dif * bounce)
	return self.pos
end

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

function squapi.bouncetowards(current, target, vel, stiff, bounce)
	local bounce = bounce or 0.05
	local stiff = stiff or 0.005	
	local dif = target - current
	vel = vel + ((dif - vel * stiff) * stiff)
	current = (current + vel) + (dif * bounce)
	return current, vel
end

return squapi