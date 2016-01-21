local state = {}



function state:init()
end


function state:enter( pre )
	ui = UI.new()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, false)
	local _, typo = spaceship.new(
			useful.nrandom(love.graphics.getWidth()/3,love.graphics.getWidth()/2),
			useful.nrandom(love.graphics.getHeight()/3,love.graphics.getHeight()/2)
			)
	local _, typo2 = spaceship.new(
			useful.nrandom(love.graphics.getWidth()/3,love.graphics.getWidth()/2),
			useful.nrandom(love.graphics.getHeight()/3,love.graphics.getHeight()/2)
			)
	for i=1,10 do
		spaceship.new(
			useful.nrandom(love.graphics.getWidth()/3,love.graphics.getWidth()/2),
			useful.nrandom(love.graphics.getHeight()/3,love.graphics.getHeight()/2),
			spaceship.mutate(spaceship.splice(typo,typo2))
			)
	end
	focus = 1
	food = {}
	for i=1,300 do
		table.insert(food,{
			x = useful.nrandom(love.graphics.getWidth(),love.graphics.getWidth()/2),
			y = useful.nrandom(love.graphics.getHeight(),love.graphics.getHeight()/2)
			})
	end
	starfield = {}
	for i=1,0 do
		table.insert(starfield,{
			x = useful.nrandom(love.graphics.getWidth(),love.graphics.getWidth()/2),
			y = useful.nrandom(love.graphics.getHeight(),love.graphics.getHeight()/2)
			})
	end
	cx, cy = nil, nil

	cam = math.random(5,15)
end


function state:leave( next )
end


function state:update(dt)
	cam = cam - dt
	if cam<0 then
		cam = math.random(5,15)
		--focus = math.random(1,#spaceship.all)
	end
	local fx, fy = spaceship.all[focus].phys.body:getPosition()
	cx, cy = useful.moveTowards2D(
		{
				x = (cx or fx),
				y = (cy or fy) 
		},{
				x = fx,
				y = fy
		}, 1500*dt)
	ui:update(dt)
	world:update(dt)
	spaceship.update(dt)
end


function state:draw()
	--ui:draw()
	spaceship.all[focus]:drawFixedUI()
	local fx, fy = spaceship.all[focus].phys.body:getPosition()
	love.graphics.translate(-cx+love.graphics.getWidth()/2,-cy+love.graphics.getHeight()/2)
	love.graphics.setColor(255,255,255)
	for i,v in ipairs(starfield) do
		local dep = useful.lerp(5,20,i/#starfield)
		love.graphics.points(v.x+cx/dep, v.y+cy/dep)
	end
	for i,v in ipairs(food) do
		love.graphics.setColor(64,196,196,127)
		love.graphics.circle("fill", v.x, v.y, 5+math.sin(love.timer.getTime()+i))
		local pls = ((love.timer.getTime()*(useful.lerp(15,25,i/#food))+i)%20)/20
		love.graphics.setColor(64,196,196,127*(1-pls))
		love.graphics.circle("line", v.x, v.y, 5+math.sin(love.timer.getTime()+i)+pls*20)
	end
	spaceship.draw()
	spaceship.all[focus]:drawOverlayUI()
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
		focus = (focus%#spaceship.all)+1
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