
--███████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗██╗   ██╗███████╗     █████╗ ██████╗ ██╗
--██╔════╝██╔═══██╗██║   ██║██║██╔════╝██║  ██║╚██╗ ██╔╝██╔════╝    ██╔══██╗██╔══██╗██║
--███████╗██║   ██║██║   ██║██║███████╗███████║ ╚████╔╝ ███████╗    ███████║██████╔╝██║
--╚════██║██║▄▄ ██║██║   ██║██║╚════██║██╔══██║  ╚██╔╝  ╚════██║    ██╔══██║██╔═══╝ ██║
--███████║╚██████╔╝╚██████╔╝██║███████║██║  ██║   ██║   ███████║    ██║  ██║██║     ██║
--╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝     ╚═╝
----------------------------------------------------------------------------------------

-- Author: Squishy
-- Discord tag: mrsirsquishy

-- Version: 0.3.0
-- Legal: Do not Redistribute without explicit permission.

-- Special Thanks to @jimmyhelp for errors and just generally helping me get things working.


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

--the smoothTorso function will enable this automatically, this will basically cancel out the heads movement based on the torsos movement so your head doesn't bend too far.
squapi.cancelHeadMovement = false
squapi.torsoOffset = vec(0,0,0)

--toggle this to enable/disable idle animations
squapi.doidleanimations = true

--toggle this variable to enable/disable all squapi animations
squapi.doAnimations = true

-- ANIMATION PLAYER


--[[

This code segment can be copy pasted to make it easier to set up your animations

squapi.animate(
	nil, --idle
	nil, --walkanim
	nil, --reversewalk
	nil, --runanim
	nil, --sidewalkleft
	nil, --sidewalkright
	nil, --armswingleft
	nil, --armswingright
	nil, --holdSwordIdle
	nil, --holdAxeIdle
	nil, --attacks 
	nil, --axeAttacks 
	nil, --holdShield 
	nil, --raiseShield 
	nil, --holdBowIdle
	nil, --chargeBow
	nil, --fireBow
	nil, --holdCrossbowIdle
	nil, --holdCrossbowCharged
	nil, --chargeCrossbow
	nil, --fireCrossbow
	nil, --crouch
	nil, --uncrouch
	nil, --crawl
	nil, --uncrawl
	nil, --crawling
	nil, --fall
	nil, --rise
	nil, --fallimpact
	nil, --elytra
	nil, --rightEat
	nil, --leftEat
	nil, --rightDrink
	nil, --leftDrink
	nil, --sitMinecart
	nil, --sitBoat
	nil, --sitHorse
	nil, --sitCamel
	nil, --sitPig
	nil, --hurt
	nil, --die
	nil, --swim
	nil, --underWaterIdle,
	nil, --underWaterMove,
	nil, --climb --doesn't work lmao
	nil, --sleep
	nil, --StopCombos
)
]]

--WIP NOTES
-- Shield anims conflict with weapon anims
-- Shield anims only work with offhand
-- Weapon anims only work in mainhand
-- If you're left handed just swap stuff around idk
-- Axe Attacks currently don't work
-- death anims are just weird
-- climb doesn't work lmao

--PLANS
-- equip animations(when item like sword equpped plays an anim)

--OTHER NOTES
--make sure to take into account how vanilla player moves when doing things like crouching, crawling, elytra, swimming as you may have to adjust for those

function squapi.animate(
	idle, --plays at all times
	walkanim, --plays when walking
	reversewalk, --plays when walking backward
	runanim, --plays when running(uses walking if nil)
	sidewalkleft, 
	sidewalkright, 
	armswingleft, 
	armswingright,
	holdSwordIdle,
	holdAxeIdle,
	attacks, --minecraft attack with sword animations, tip: sword attack cooldown is .625 seconds. 
	axeAttacks, --minecraft attack with axe animations, tip: axe attack cooldown is 1.25 seconds.(falls back to attacks)
	holdShield, --this will play whenever the shield is in the offhand, note it plays on top of any animation currently playing, and does not override.
	raiseShield, --plays when you raise your shield in the offhand
	holdBowIdle,
	chargeBow,
	fireBow,
	holdCrossbowIdle,
	holdCrossbowCharged,
	chargeCrossbow,
	fireCrossbow,
	crouch,
	uncrouch,
	crawl,
	uncrawl,
	crawling,
	fall,
	rise,
	fallimpact,
	elytra,
	rightEat,
	leftEat,
	rightDrink,
	leftDrink,
	sitMinecart,
	sitBoat,
	sitHorse,
	sitCamel,
	sitPig,
	hurt,
	die,
	swim,
	underWaterIdle,
	underWaterMove,
	climb, --doesn't work lmao
	sleep,
	StopCombos
	)
	--initiates settings variables
	if StopCombos == nil then StopCombos = true end

	--initiates animations with fallbacks
	local sidewalkleft = sidewalkleft or walkanim
	local sidewalkright = sidewalkright or sidewalkleft
	local crawling = crawling or walkanim
	local rightDrink = rightDrink or rightEat
	local leftDrink = leftDrink or leftEat
	local attacks = attacks or armswingleft
	local sitBoat = sitBoat or sitMinecart
	local sitHorse = sitHorse or sitMinecart
	local sitCamel = sitCamel or sitHorse
	local sitPig = sitPig or sitHorse

	-- initiates bounce objects
	local walksmooth = squapi.bounceObject:new()
	local runsmooth = squapi.bounceObject:new()
	local sidewalksmooth = squapi.bounceObject:new()
	local fallsmooth = squapi.bounceObject:new()
	local risesmooth = squapi.bounceObject:new()
	local elytrasmooth = squapi.bounceObject:new()
	local reversesmooth = squapi.bounceObject:new()
	local idlesmooth = squapi.bounceObject:new()
	local swordsmooth = squapi.bounceObject:new()
	local axesmooth = squapi.bounceObject:new()
	local bowsmooth = squapi.bounceObject:new()
	local crossbowsmooth = squapi.bounceObject:new()
	local chargedsmooth = squapi.bounceObject:new()
	local shieldsmooth = squapi.bounceObject:new()
	local raiseshieldsmooth = squapi.bounceObject:new()

	--initiates animations
	if idle then idle:play() end
	if holdSwordIdle then holdSwordIdle:play() end
	if holdAxeIdle then holdAxeIdle:play() end
	if holdBowIdle then holdBowIdle:play() end
	if holdCrossbowIdle then holdCrossbowIdle:play() end
	if runanim and walkanim then runanim:play() end
	if walkanim then walkanim:play() end
	if reversewalk then reversewalk:play() end
	if sidewalkleft then sidewalkleft:play() end
	if sidewalkright then sidewalkright:play() end
	if rise then rise:play() end
	if fall then fall:play() end
	if crawling then crawling:play() end
	if elytra then elytra:play() end
	if type(attacks) == "Animation" then
		attacks = {attacks}
	end
	if holdShield then holdShield:play() end
	if raiseShield then raiseShield:play() end
	if holdCrossbowCharged then holdCrossbowCharged:play() end
	if swim then swim:play() end
	if underWaterIdle then underWaterIdle:play() end
	if underWaterMove then underWaterMove:play() end

	--remembers active animations
	local constants = {
		idle,
		holdSwordIdle,
		holdAxeIdle,
		holdBowIdle,
		holdCrossbowIdle,
		runanim,
		walkanim,
		reversewalk,
		sidewalkleft,
		sidewalkright,
		rise,
		fall,
		crawling,
		elytra,
		holdShield,
		raiseShield,
		holdCrossbowCharged,
		swim,
		underWaterIdle,
		underWaterMove
	}
	
	local oldpose = "STANDING"
	local oldswingtime = nil
	local combo = 1
	local combotimer = 1
	local oldsit = nil
	local oldhealth = 0
	local olduseAction = "NONE"
	local wascharged = false
	local doWater = swim or underWaterIdle or underWaterMove
	local arialtime = 0
	local wasAnimations = squapi.doAnimations
	--loop because duh
	function events.render()
		
	local pose = player:getPose()
	if pose == "SWIMMING" and not player:isInWater() then pose = "CRAWLING" end

	if squapi.doAnimations and pose ~= "SLEEPING" then

			--reinitializes animations 
			if wasAnimations == false then
				for i, v in ipairs(constants) do
					if v then
						v:play()
					end
				end
				if sleep then sleep:stop() end
			end
			--setup variables
			local swing = player:getSwingArm()
			local swingtime = player:getSwingTime()
			local speed = false
			for i = 0, #(host:getStatusEffects()), 1 do
				if host:getStatusEffects()[i] ~= nil then
					speed = host:getStatusEffects()[i].name == "effect.minecraft.speed"
				end
			end
			local vel = math.max(-0.3, math.min(0.3, squapi.getForwardVel()))
			local yvel = squapi.yvel()
			local svel = math.max(-0.3, math.min(0.3, squapi.getSideVelocity()))
			local mainhand = player:getItem(1)
			local offhand = player:getItem(2)
			local sit = player:getVehicle()
			local health = player:getHealth()
			local grounded = player:isOnGround()
			local useAction = player:getActiveItem():getUseAction()
			local charged = mainhand.tag["Charged"] == 1
			local water = player:isInWater()
			local underwater = player:isUnderwater()

			local arialstop = (arialtime > 10 and (fall ~= nil or rise ~=nil))

			--IDLES AND BOW
			local isattacking = false
			if attacks then
				for i, v in ipairs(attacks) do
					if v:isPlaying() and v:getTime() < v:getLength()-.1 then
						isattacking = true
					end
				end
			end

			--BOW/CROSSBOW
			if useAction == "BOW" then --charging bow
				if fireBow then fireBow:stop() end
				isattacking = true
				if chargeBow then chargeBow:play() end
				bowsmooth.pos = 0
			elseif useAction == "CROSSBOW" then --charging crossbow
				if fireCrossbow then fireCrossbow:stop() end
				isattacking = true
				if chargeCrossbow then chargeCrossbow:play() end
				crossbowsmooth.pos = 0
			elseif not charged and wascharged and player:getHeldItem().id:find("crossbow") then
				fireCrossbow:play()
				chargeCrossbow:stop()
			elseif olduseAction == "BOW" and player:getHeldItem().id:find("bow") then --fire bow
				if chargeBow then chargeBow:stop() end
				if fireBow then fireBow:play() end
			else
				if chargeBow then chargeBow:stop() end
				if chargeCrossbow then chargeCrossbow:stop() end
			end

			if fireBow and fireBow:isPlaying() and fireBow:getTime() < fireBow:getLength()/2 then 
				chargeBow:stop()
				isattacking = true 
				bowsmooth.pos = 0 
			end
			if fireCrossbow and fireCrossbow:isPlaying() and fireCrossbow:getTime() < fireCrossbow:getLength()/2 then
				chargeCrossbow:stop()
				isattacking = true
				crossbowsmooth.pos = 0
				chargedsmooth.pos = 0
			end
			

			--SHIELD
			if offhand.id:find("shield") then
				if useAction == "BLOCK" then
					if raiseShield then
						raiseShield:setBlend(raiseshieldsmooth:doBounce(1, .1, .5))
						if holdShield then holdShield:setBlend(shieldsmooth:doBounce(0, .1, .8)) end
					else
						if holdShield then holdShield:setBlend(shieldsmooth:doBounce(1, .001, .1)) end
					end
				else
					if raiseShield then raiseShield:setBlend(raiseshieldsmooth:doBounce(0, .1, .5)) end
					if holdShield then 
						holdShield:setBlend(shieldsmooth:doBounce(1, .001, .1))
					end
				end
			else
				if raiseShield then raiseShield:setBlend(raiseshieldsmooth:doBounce(0, .1, .5)) end
				if holdShield then holdShield:setBlend(shieldsmooth:doBounce(0, .001, .1)) end
			end
			

			--IDLES
			if squapi.doidleanimations and grounded and pose == "STANDING" and not isattacking  and vel > -.2 and vel < .2 and svel < .1 and svel > -.1then
				if holdSwordIdle and player:getHeldItem().id:find("sword") then
					holdSwordIdle:setBlend(swordsmooth:doBounce(1, .001, .1))
					if holdAxeIdle then holdAxeIdle:setBlend(axesmooth:doBounce(0, .001, .1)) end
					if idle then idle:setBlend(idlesmooth:doBounce(0, .001, .1)) end
					if holdBowIdle then holdBowIdle:setBlend(bowsmooth:doBounce(0, .001, .1)) end
					if holdCrossbowIdle then holdCrossbowIdle:setBlend(crossbowsmooth:doBounce(0, .001, .1)) end
					if holdCrossbowCharged then holdCrossbowCharged:setBlend(chargedsmooth:doBounce(0, .001, .1)) end

				elseif holdAxeIdle and player:getHeldItem().id:find("axe") and player:getHeldItem().id:find("pick") == nil then
					holdAxeIdle:setBlend(axesmooth:doBounce(1, .001, .1))
					if holdSwordIdle then holdSwordIdle:setBlend(swordsmooth:doBounce(0, .001, .1)) end
					if idle then idle:setBlend(idlesmooth:doBounce(0, .001, .1)) end
					if holdBowIdle then holdBowIdle:setBlend(bowsmooth:doBounce(0, .001, .1)) end
					if holdCrossbowIdle then holdCrossbowIdle:setBlend(crossbowsmooth:doBounce(0, .001, .1)) end
					if holdCrossbowCharged then holdCrossbowCharged:setBlend(chargedsmooth:doBounce(0, .001, .1)) end

				elseif holdCrossbowIdle and player:getHeldItem().id:find("crossbow") then --crossbow
					if charged and holdCrossbowCharged then 
						holdCrossbowCharged:setBlend(chargedsmooth:doBounce(1, .001, .1))
						holdCrossbowIdle:setBlend(crossbowsmooth:doBounce(0, .001, .1))
					else
						holdCrossbowIdle:setBlend(crossbowsmooth:doBounce(1, .001, .1))
						holdCrossbowCharged:setBlend(chargedsmooth:doBounce(0, .001, .1))
					end

					if holdAxeIdle then holdAxeIdle:setBlend(axesmooth:doBounce(0, .001, .1)) end
					if idle then idle:setBlend(idlesmooth:doBounce(0, .001, .1)) end
					if holdBowIdle then holdBowIdle:setBlend(bowsmooth:doBounce(0, .001, .1)) end
					if holdSwordIdle then holdSwordIdle:setBlend(swordsmooth:doBounce(0, .001, .1)) end

				elseif holdBowIdle and player:getHeldItem().id:find("bow") then --bow
					holdBowIdle:setBlend(bowsmooth:doBounce(1, .001, .1))
					if holdSwordIdle then holdSwordIdle:setBlend(swordsmooth:doBounce(0, .001, .1)) end
					if holdAxeIdle then holdAxeIdle:setBlend(axesmooth:doBounce(0, .001, .1)) end
					if idle then idle:setBlend(idlesmooth:doBounce(0, .001, .1)) end
					if holdCrossbowIdle then holdCrossbowIdle:setBlend(crossbowsmooth:doBounce(0, .001, .1)) end
					if holdCrossbowCharged then holdCrossbowCharged:setBlend(chargedsmooth:doBounce(0, .001, .1)) end

				else
					if idle then idle:setBlend(idlesmooth:doBounce(1, .001, .1)) end
					if holdSwordIdle then holdSwordIdle:setBlend(swordsmooth:doBounce(0, .001, .1)) end
					if holdAxeIdle then holdAxeIdle:setBlend(axesmooth:doBounce(0, .001, .1)) end
					if holdBowIdle then holdBowIdle:setBlend(bowsmooth:doBounce(0, .001, .1)) end
					if holdCrossbowIdle then holdCrossbowIdle:setBlend(crossbowsmooth:doBounce(0, .001, .1)) end
					if holdCrossbowCharged then holdCrossbowCharged:setBlend(chargedsmooth:doBounce(0, .001, .1)) end
				end
			else
				if idle then idle:setBlend(idlesmooth:doBounce(0, .001, .1)) end
				if holdSwordIdle then holdSwordIdle:setBlend(swordsmooth:doBounce(0, .001, .1)) end
				if holdAxeIdle then holdAxeIdle:setBlend(axesmooth:doBounce(0, .001, .1)) end
				if holdBowIdle then holdBowIdle:setBlend(bowsmooth:doBounce(0, .001, .1)) end
				if holdCrossbowIdle then holdCrossbowIdle:setBlend(crossbowsmooth:doBounce(0, .001, .1)) end
				if holdCrossbowCharged then holdCrossbowCharged:setBlend(chargedsmooth:doBounce(0, .001, .1)) end
			end
			



			--Damage + Death
			if oldhealth > health then
				hurt:play()
			end
			if health == 0 then
				die:play()
			end


			--Sitting Animations
			if sit ~= nil then
				idle:stop()
				walkanim:stop()
				runanim:stop()
				sidewalkleft:stop()
				sidewalkright:stop()
				if sit:getName() == "Minecart" and sitMinecart ~= nil then
					sitMinecart:play()
				elseif sit:getName() == "Boat" and sitBoat ~= nil then
					sitBoat:play()
				elseif sit:getName() == "Horse" and sitHorse ~= nil then
					sitHorse:play()
				elseif sit:getName() == "Camel" and sitCamel ~= nil then
					sitCamel:play()
				elseif sit:getName() == "Pig" and sitPig ~= nil then
					sitPig:play()
				end
			elseif oldsit ~= nil then
				sitBoat:stop()
				sitMinecart:stop()
				sitHorse:stop()
				sitCamel:stop()
				sitPig:stop()
				if idle ~= nil then idle:play() end
				if runanim ~= nil and walkanim ~= nil then runanim:play() end
				if walkanim ~= nil then walkanim:play() end
				if sidewalkleft ~= nil then sidewalkleft:play() end
				if sidewalkright ~= nil then sidewalkright:play() end
			end


			--Elytra
			if elytra ~= nil then
				if pose == "FALL_FLYING" then
					elytra:setBlend(elytrasmooth:doBounce(1, .001, .1))
					if walkanim ~= nil then walkanim:setBlend(0) end
					if runanim ~= nil then walkanim:setBlend(0) end
				else
					elytra:setBlend(elytrasmooth:doBounce(0, .001, .1))
				end
			end


			--fall impact animation
			if fallimpact ~= nil then
				if arialtime > 10 and yvel < 0 and grounded and not fallimpact:isPlaying() then
					fallimpact:setBlend(math.min(-yvel*2.5 + 0.4, 2))
					fallimpact:setSpeed(math.max(1+yvel/2, .5))
					fallimpact:play()
				end
			end
			
			
			--fall, rise, jump animations
			if fall ~= nil and rise ~= nil and pose ~= "FALL_FLYING" and not grounded then
				if yvel < 0 then	
					fall:setBlend(fallsmooth:doBounce(-math.max(yvel*2, -1), .001, .1))
					rise:setBlend(risesmooth:doBounce(0, .001, .1))
				else 
					rise:setBlend(risesmooth:doBounce(math.min(yvel*3, 1.2), .001, .1))
					fall:setBlend(fallsmooth:doBounce(0, .001, .1))
				end
				fall:setSpeed(fallsmooth.pos)
				rise:setSpeed(risesmooth.pos)
			else
				if fall then fall:setBlend(fallsmooth:doBounce(0, .001, .1)) end
				if rise then rise:setBlend(risesmooth:doBounce(0, .001, .1)) end
			end

			-- Crouch, UnCrouch, Crawl, and UnCrawl

			if crouch ~= nil then
				if pose == "CROUCHING" then
					
					if uncrouch ~= nil then
						uncrouch:stop()
					end
					crouch:play()
				
				elseif oldpose == "CROUCHING" then
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
					elseif oldpose == "CRAWLING" then
						crawl:stop()
						if uncrawl ~= nil then
							uncrawl:play()
						end
					end

				end
			end

			--eat/drink animations

			if player:isUsingItem() then
				if player:getActiveHand() == "MAIN_HAND" then
					if mainhand:getUseAction() == "EAT" then
						if rightEat~=nil then rightEat:play() end
					elseif mainhand:getUseAction() == "DRINK" then
						if rightDrink ~= nil then rightDrink:play() end
					end
				end

				if player:getActiveHand() == "OFF_HAND" then
					if offhand:getUseAction() == "EAT" then
						if leftEat~=nil then leftEat:play() end
					elseif offhand:getUseAction() == "DRINK" then
						if leftDrink ~= nil then leftDrink:play() end
					end
				end
			else 
				if rightEat~=nil then rightEat:stop() end
				if leftEat~=nil then leftEat:stop() end
				if leftDrink ~= nil then leftDrink:stop() end
				if rightDrink ~= nil then rightDrink:stop() end
			end



			--armswing animation

			local punch = nil
			if swingtime == 1 and oldswingtime == 0 then
				punch = swing
			end

			if not StopCombos then
				combotimer = 50
			end
			if attacks ~= nil then
				if combo > #attacks then combo = 1 end

				if combotimer > 1 then
					combotimer = combotimer - 1
				else
					combo = 1
				end
			end

			if armswingright ~= nil and armswingleft ~= nil then
				if punch == "MAIN_HAND" then
					if attacks ~= nil and (player:getHeldItem().id:find("sword") ~= nil or (player:getHeldItem().id:find("axe") ~= nil and player:getHeldItem().id:find("pick") == nil)) then
						for i, a in pairs(attacks) do
							a:stop()
						end
						attacks[combo]:play()
						combo = combo + 1
						combotimer = 80
					else
						armswingleft:stop()
						armswingleft:play()
					end
					
				end
				if punch == "OFF_HAND" then
					armswingright:stop()
					armswingright:play()
				end
			end
			
		
			--Sideways walk animation

			if sidewalkleft ~= nil and sidewalkright ~= nil and pose ~= "FALL_FLYING" and pose ~= "CROUCHING" and not arialstop then
				if svel > 0 then
					sidewalkright:setBlend(sidewalksmooth:doBounce(svel*4.633, .001, .2))
					sidewalkright:setSpeed(-sidewalksmooth.pos)
					sidewalkleft:setBlend(0)
				else
					sidewalkleft:setBlend(-sidewalksmooth:doBounce(svel*4.633, .001, .2))
					sidewalkleft:setSpeed(sidewalksmooth.pos)
					sidewalkright:setBlend(0)
				end
			else
				if sidewalkright then sidewalkright:setBlend(0) end
				if sidewalkleft then sidewalkleft:setBlend(0) end
			end
			

			-- MOVEMENT ANIMATIONS!!!
			walksmooth.vel = math.max(math.min(walksmooth.vel, .01), -.01)
			--runsmooth.vel = math.max(math.min(runsmooth.vel, .002), -.002)
			reversesmooth.pos = math.max(math.min(reversesmooth.pos, 1), 0)
			walksmooth.pos = math.max(math.min(walksmooth.pos, 1), 0)
			runsmooth.pos = math.max(math.min(runsmooth.pos, 1), 0)
			
			if walkanim ~= nil and pose ~= "FALL_FLYING" and (not arialstop or water) then
				local walk = walkanim
				if crawling ~= nil and pose == "CRAWLING" then
					walkanim:setBlend(0)
					walk = crawling
					vel = math.sqrt(vel^2 + svel^2)
				elseif water then
					walkanim:setBlend(0)
					if crawling then crawling:setBlend(0) end
					if pose == "SWIMMING" then
						walk = swim
						underWaterMove:setBlend(0)
						vel = math.sqrt(vel^2 + svel^2)*1.5
					else
						walk = underWaterMove
						swim:setBlend(0)
						vel = math.sqrt(vel^2 + svel^2)*2

					end
				else 
					if crawling then crawling:setBlend(0) end
					if swim then swim:setBlend(0) end
					if underWaterMove then underWaterMove:setBlend(0) end
				end
				if sidewalkleft == walk then vel = math.sqrt(vel^2 + svel^2) end
				local target = vel*4.633
				if crawling ~= nil and pose == "CRAWLING" then
					target = vel*15.504
				elseif not runanim and player:isSprinting() then
					target = target*2
				end
				
				if reversewalk then
					if vel >= 0 then
						walk:setBlend(walksmooth:doBounce(target, .001, .2))
						reversewalk:setBlend(reversesmooth:doBounce(0, .001, .2))
					else
						walk:setBlend(walksmooth:doBounce(0, .001, .2))
						reversewalk:setBlend(reversesmooth:doBounce(-target, .001, .2))
					end
				else
					walk:setBlend(walksmooth:doBounce(target, .001, .2))
				end
				

				if speed then
					walkanim:setSpeed(walksmooth.pos*1.5)
				else
					walkanim:setSpeed(walksmooth.pos)
				end
				
				-- Run Animation
				if runanim ~= nil then
					
					if player:isSprinting() and not water then
						walk:setBlend(0)
						
						local target = math.max(vel*3.57, 0)
						--prevents wierd issue when looking up
						if target == 0 then
							target = 1
						end

						if runsmooth.pos < 0 then
							runsmooth.pos = runsmooth.pos * -4
						end

						runanim:setBlend(runsmooth:doBounce(target, .001, .2))
						
						if speed then
							runanim:setSpeed(runsmooth.pos*1.5)
						else
							runanim:setSpeed(runsmooth.pos)
						end
					else
						runanim:setBlend(runsmooth:doBounce(0, .1, .1))
						runanim:setSpeed(runsmooth.pos)
					end
				end

			else
				
				if runanim then runanim:setBlend(runsmooth:doBounce(0, .02, .1)) end
				if walkanim then walkanim:setBlend(walksmooth:doBounce(0, .02, .1)) end
				if crawling then crawling:setBlend(0) end
				if swim then swim:setBlend(0) end
				if underWaterMove then underWaterMove:setBlend(0) end
				if reversewalk then reversewalk:setBlend(reversesmooth:doBounce(0, .02, .1)) end
			end


			--memorizes variables from last iteration
			if grounded then 
				arialtime = 0
			else
				arialtime = arialtime + 1
			end
			oldpose = pose
			oldswingtime = swingtime
			oldsit = sit
			oldhealth = health
			olduseAction = useAction
			wascharged = charged
		else
			for i, v in ipairs(constants) do
				if v then
					v:stop()
				end
			end
			if squapi.doAnimations then
				if sleep then sleep:play() end
			else
				if sleep then sleep:stop() end
			end

		end

		wasAnimations = squapi.doAnimations
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

squapi.floatPoint = {}
squapi.floatPoint.__index = squapi.floatPoint
function squapi.floatPoint.new(element, xoffset, yoffset, zoffset, stiffness, bouncy, ymin, maxradius)
  local self = setmetatable({}, squapi.floatPoint)
  self.element = element
  assert(self.element,
  "§4The float point's model path is incorrect.§c")
  self.element:setParentType("WORLD")
  self.point = {
	  squapi.bounceObject:new(), 
	  squapi.bounceObject:new(), 
	  squapi.bounceObject:new(), 
	  squapi.bounceObject:new()
  }
  self.stiff = stiffness or .02
  self.bounce = bouncy or .0005

  self.rotstiff = .0005
  self.rotbounce =  .03

  self.ymin = ymin or 30
  self.maxradius = maxradius or nil
  self.init = true

  self.x = xoffset or 0
  self.y = yoffset or 0
  self.z = zoffset or 0

  self.active = true
  function self.disable()
	self.active = false --sets active false
  end
  function self.enable() --sets active true
	self.active = true
  end
  function self.toggle() --toggles activeness
	self.active = not self.active
  end

  function events.render(delta, context) --rendering always running
		if self.init then
			self.point[1].pos = player:getPos()[1]*16 + self.x
			self.point[2].pos = player:getPos()[2]*16 + self.y
			self.point[3].pos = player:getPos()[3]*16 + self.z
			self.point[4].pos = -player:getBodyYaw()-180

			self.init = false
		end
		
		local targetx = player:getPos()[1]*16
		local targety = player:getPos()[2]*16
		local targetz = player:getPos()[3]*16
		local targetrot = -player:getBodyYaw()-180
		
		--avoids going to low/getting to far based on radius and miny
		self.stiff = stiffness or .02
		self.bounce = bouncy or .0005
		if self.point[2].pos-player:getPos()[2]*16 < -self.ymin then
			self.stiff = 0.035
			self.bounce = .01
		elseif self.maxradius ~= nil then
			if  
				point[1].pos-player:getPos()[1]*16 < -self.maxradius 
				or point[1].pos-player:getPos()[1]*16 > self.maxradius  
				or point[2].pos-player:getPos()[2]*16 < -self.maxradius 
				or point[2].pos-player:getPos()[2]*16 > self.maxradius 
				or point[3].pos-player:getPos()[3]*16 < -self.maxradius 
				or point[3].pos-player:getPos()[3]*16 > self.maxradius 
				then
					
					self.stiff = self.stiff*0.57
					self.bounce = self.bounce * 400		
			end
		end
		
		--local truepos = element:getPos() - player:getPos()*16
		if self.active then
			self.element:setPivot(-self.x,-self.y,-self.z)
			self.element:setPos(
				self.point[1]:doBounce(targetx, self.bounce, self.stiff) + self.x,
				self.point[2]:doBounce(targety, self.bounce, self.stiff) + self.y, 
				self.point[3]:doBounce(targetz, self.bounce, self.stiff) + self.z
			)
			self.element:setRot(0, self.point[4]:doBounce(targetrot, self.rotstiff, self.rotbounce), 0)
		end
	end


  return self
end



--BOUNCE WALK
-- guide:(note if it has a * that means you can leave it blank to use reccomended settings)
-- model:			the path to your model element. Most cases, if you're model is named "model", than it'd be models.model (replace model with the name of your model) 
-- *bounceMultipler:normally 1, this multiples how much the bounce occurs. values greater than 1 will increase bounce, and values less than 1 will decrease bounce.
function squapi.bouncewalk(model, bounceMultipler)
	assert(model,
	"§4Your model path for bouncewalk is incorrect.§c")
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
	assert(element,
	"§4Your model path for smoothTorso is incorrect.§c")
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
	assert(element,
	"§4Your model path for smoothHead is incorrect.§c")
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
-- *tilt:				how strong the heads extra tilt factor is(this adds more character)
-- *strength:			how much the head should follow vanill movements. .5 means half, 2 means double.
-- *keeporiginalheadpos: when true(automatically true) the heads position will change like normally, set to false to disable.
function squapi.smoothHeadNeck(element, element2, tilt, strength, keeporiginalheadpos)
	assert(element,
	"§4Your head model path for smoothHeadNeck is incorrect.§c")
	assert(element2,
	"§4Your neck model path for smoothHeadNeck is incorrect.§c")
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
	assert(element,
	"§4Your eye model path is incorrect.§c")
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
		if y < -down then y = -down end

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
function squapi.blink(animation, chancemultiplier)
	local chancemultiplier = chancemultiplier or 1
	local blinkObject = squapi.randimation.new(animation, chancemultiplier*200)

	function events.tick()
		local pose = player:getPose()
		if pose == "SLEEPING" or squapi.doBlink == false then
			blinkObject:setEnabled(false)
		else
			blinkObject:setEnabled(true)
		end
	end
end

--RANDOM ANIMATION OBJECT
--this object will take in an animation and plays it randomly every tick by a specified amount. 
--*chanceRange is an optional paramater that sets the range. 0 means every tick, larger values mean lower chances of playing every tick.
--setEnabled() function will take in a boolean and sets weather the randimation is enabled/disabled.
squapi.randimation = {}
squapi.randimation.__index = squapi.randimation
function squapi.randimation.new(animation, chanceRange)
	local self = setmetatable({}, squapi.floatPoint)
	self.animation = animation
	self.chanceRange = chanceRange or 200
	self.enabled = true

	function self:setEnabled(state)
		self.enabled = state
	end


	function events.tick()
		if self.enabled and math.random(0, self.chanceRange) == 0 and self.animation:isStopped() then
			self.animation:play()
		end
	end

	return self
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
	assert(type(tailsegs) == "table", 
	"your tailsegs table seems to to be incorrect")
	
	for i = 1, #tailsegs do
		assert(tailsegs[i]:getType() == "GROUP",
		"§4The tail segment at position "..i.." of the table is not a group. The tail segments need to be groups that are nested inside the previous segment.§c")
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
		local tailintensity = tailintensity/(math.abs((yvel*30))+vel*30 + 1)

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
	assert(element,
	"§4The first ear's model path is incorrect.§c")

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
	assert(element,
	"§4Your model path for bewb is incorrect.§c")
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
	assert(element,
	"§4Your model path for animateTexture is incorrect.§c")
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
	assert(element,
	"§4Your model path for setFirstPersonHandPos is incorrect.§c")
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
	assert(taurbody,
	"§4Your model path for the body in taurPhysics is incorrect.§c")
	assert(frontlegs,
	"§4Your model path for the front legs in taurPhysics is incorrect.§c")
	assert(backlegs,
	"§4Your model path for the back legs in taurPhysics is incorrect.§c")
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



--LEGACY FLOAT POINT

function squapi.floatPointOld(element, xoffset, yoffset, zoffset, stiffness, bouncy, ymin, maxradius)
	assert(element,
	"§4The float point's model path is incorrect.§c")
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


return squapi