
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




return squapi