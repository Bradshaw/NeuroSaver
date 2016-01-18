local state = {}



function state:init()
end


function state:enter( pre )
	--ui = UI.new()
	net = neuro.new(2,3,6,4)
	canv = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
	skipIn = 1
	net:update()
	xness = 0
	yness = 0
	local w = 30
	local h = 30
	love.graphics.setCanvas(canv)
	for i=0,love.graphics.getWidth(),w do
		for j=0,love.graphics.getHeight(),h do
			net.ins[1] = ((i+w/2)/love.graphics.getWidth())*2-1
			net.ins[2] = ((j+h/2)/love.graphics.getHeight())*2-1
			net:update()
			---[[
			local r = net.outs[1]>=0 and net.outs[1]*255 or 0
			local g = net.outs[2]>=0 and net.outs[2]*255 or 0
			local b = net.outs[3]>=0 and net.outs[3]*255 or 0
			--]]
			--local r,g,b = neuro.color(net.outs[1])
			love.graphics.setColor(r,g,b)
			love.graphics.rectangle("fill", i, j, w, h)
		end
	end
	love.graphics.setCanvas()
end


function state:leave( next )
end


function state:update(dt)
	local w = 1
	local h = 1
	local t = love.timer.getTime();
	love.graphics.setCanvas(canv)
	for i=xness,love.graphics.getWidth(),w do
		if (love.timer.getTime()-t>skipIn) then
			break
		end
		xness = i
		for j=yness,love.graphics.getHeight(),h do
			if (love.timer.getTime()-t>skipIn) then
				break
			end
			yness = j
			net.ins[1] = ((i+w/2)/love.graphics.getWidth())*2-1
			net.ins[2] = ((j+h/2)/love.graphics.getHeight())*2-1
			net:update()
			---[[
			local r = net.outs[1]>=0 and net.outs[1]*255 or 0
			local g = net.outs[2]>=0 and net.outs[2]*255 or 0
			local b = net.outs[3]>=0 and net.outs[3]*255 or 0
			--]]
			--local r,g,b = neuro.color(net.outs[1])
			love.graphics.setColor(r,g,b)
			love.graphics.rectangle("fill", i, j, w, h)
		end
		yness = 0
	end
	love.graphics.setCanvas()
end


function state:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(canv)
	if xness<love.graphics.getWidth() then
		love.graphics.print(xness.." / "..love.graphics.getWidth(),100,100)
		love.graphics.print(math.floor((xness/love.graphics.getWidth())*100).."%",100,130)
	end
	--ui:draw()
	---[[
	--]]
	--net:draw()
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