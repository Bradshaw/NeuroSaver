local state = {}



function state:init()
end


function state:enter( pre )
	ui = UI.new()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, false)
	spaceship.new(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	for i=1,10 do
		spaceship.new(
			(math.random())*love.graphics.getWidth(),
			(math.random())*love.graphics.getHeight()
			)
	end
	focus = 1
	food = {}
	for i=1,1000 do
		table.insert(food,{
			x = (math.random()*3-1)*love.graphics.getWidth(),
			y = (math.random()*3-1)*love.graphics.getHeight()
			})
	end
	starfield = {}
	for i=1,0 do
		table.insert(starfield,{
			x = (math.random()*3-1)*love.graphics.getWidth(),
			y = (math.random()*3-1)*love.graphics.getHeight()
			})
	end
end


function state:leave( next )
end


function state:update(dt)
	--print(dt)
	ui:update(dt)
	world:update(dt)
	spaceship.update(dt)
end


function state:draw()
	spaceship.all[focus].net:draw()
	local fx, fy = spaceship.all[focus].phys.body:getPosition()
	love.graphics.translate(-fx+love.graphics.getWidth()/2,-fy+love.graphics.getHeight()/2)
	love.graphics.setColor(255,255,255)
	for i,v in ipairs(starfield) do
		love.graphics.points(v.x, v.y)
	end
	love.graphics.setColor(64,196,64,127)
	for i,v in ipairs(food) do
		love.graphics.circle("fill", v.x, v.y, 5+math.sin(love.timer.getTime()+i))
	end
	love.graphics.setColor(64,64,64)
	love.graphics.circle("fill", fx, fy, 30)
	--ui:draw()
	spaceship.draw()
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
		print("switch")
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