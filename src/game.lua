local state = {}



function state:init()
end

function selectNext()
	if #spaceship.all>0 then
		cam = math.random(5,15)
		focus = (focus%#spaceship.all)+1
	else
		focus = 0
	end
end

ssdistance = 500
sscount = 20
fooddistance = 1500
foodcount = 50


function newSpecies()
	for i=1,1 do
		spaceship.new(
			useful.nrandom(ssdistance),
			useful.nrandom(ssdistance)
			)
	end
end

function speciesFrom(deathlist)
	for i,v in ipairs(deathlist) do
		v = spaceship.new(
			useful.nrandom(ssdistance),
			useful.nrandom(ssdistance),
			spaceship.mutate(v.typo)
			)
	end
end


function state:enter( pre )
	ui = UI.new()
	love.physics.setMeter(64)
	spaceship.all = {}
	if world then
		world:destroy()
	end
	world = love.physics.newWorld(0, 0, false)
	if deathlist then
		speciesFrom(deathlist)
	else
		newSpecies()
	end
	deathlist = {}
	--[[
	local _, typo = spaceship.new(
			useful.nrandom(1000),
			useful.nrandom(1000)
			)
	local _, typo2 = spaceship.new(
			useful.nrandom(1000),
			useful.nrandom(1000)
			)
	--]]
	focus = 1
	food = {}
	for i=1,foodcount do
		table.insert(food,{
			x = useful.nrandom(fooddistance),
			y = useful.nrandom(fooddistance)
			})
	end
	starfield = {}
	for i=1,2000 do
		table.insert(starfield,{
			x = useful.nrandom(2000),
			y = useful.nrandom(2000)
			})
	end
	dust = {}

	cx, cy = nil, nil

	cam = math.random(5,15)
end


function state:leave( next )
end


function state:update(dt)
	cam = cam - dt
	if cam<0 then
		cam = math.random(5,15)
		selectNext()
	end
	if focus>0 then
		local fx, fy = spaceship.all[focus].x,spaceship.all[focus].y
		--[[
		cx, cy = useful.moveTowards2D(
			{
					x = (cx or fx),
					y = (cy or fy) 
			},{
					x = fx,
					y = fy
			}, 6000*dt)
		--]]
		cx = useful.lerp((cx or fx), fx, 5*dt)
		cy = useful.lerp((cy or fy), fy, 5*dt)
	end
	ui:update(dt)
	world:update(dt)
	spaceship.update(dt)
	if #spaceship.all==0 then
		gstate.switch(game)
	end
end


function state:draw()
	love.graphics.setColor(0,20,20)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	if focus>0 then
		if focus>#spaceship.all or spaceship.all[focus].purge then
			focus = 0
			cam = math.min(cam,1)
		end
	end
	if focus>0 then
		spaceship.all[focus]:drawFixedUI()
	end
	love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	local sc = math.max(1,love.graphics.getWidth()/1500)
	--love.graphics.scale(sc,sc)
	if focus>0 then
		--love.graphics.rotate(-spaceship.all[focus].phys.body:getAngle())
	end
	love.graphics.translate(-cx,-cy)
	for i,v in ipairs(starfield) do
		love.graphics.setColor(255,255,255,255*i/#starfield)
		local dep = useful.lerp(1,2,i/#starfield)
		love.graphics.points(v.x+cx/dep, v.y+cy/dep)
	end
	for i,v in ipairs(food) do
		love.graphics.setColor(64,196,196,127)
		love.graphics.circle("fill", v.x, v.y, 5+math.sin(love.timer.getTime()+i))
		local pls = ((love.timer.getTime()*(useful.lerp(15,25,i/#food))+i)%20)/20
		love.graphics.setColor(64,196,196,127*(1-pls))
		love.graphics.circle("line", v.x, v.y, pls*20)
	end
	spaceship.draw()
	if focus>0 then
		spaceship.all[focus]:drawOverlayUI()
	end
	love.graphics.origin()
	ui:draw()
end



function state:errhand(msg)
end


function state:focus(f)
end


function state:keypressed(key, isRepeat)
	if key=='escape' then
		love.event.push('quit')
	end
	if key=="space" then
		gstate.switch(game)
	end
end


function state:keyreleased(key, isRepeat)
end


function state:mousefocus(f)
end


function state:mousepressed(x, y, btn)
end


function state:mousereleased(x, y, btn)
end


function state:quit()
end


function state:resize(w, h)
end


function state:textinput( t )
end


function state:threaderror(thread, errorstr)
end


function state:visible(v)
end


function state:gamepadaxis(joystick, axis)
end


function state:gamepadpressed(joystick, btn)
end


function state:gamepadreleased(joystick, btn)
end


function state:joystickadded(joystick)
end


function state:joystickaxis(joystick, axis, value)
end


function state:joystickhat(joystick, hat, direction)
end


function state:joystickpressed(joystick, button)
end


function state:joystickreleased(joystick, button)
end


function state:joystickremoved(joystick)
end

return state