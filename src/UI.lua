local UI_mt = {}
UI = {}

function UI.new()
	local self = setmetatable({},{__index=UI_mt})
	self.grid = 64
	self.wid = 0


	return self
end


function UI_mt:update(dt)
	-- body
end

function UI_mt:draw()
	self.wid = 0
	doWindow(0,0,2,3,self)
	doWindow(5,3,1,1,self)
	doWindow(6,3,1,1,self)
	doWindow(7,3,1,1,self)
	doWindow(8,3,1,1,self)
	doGrid(self.grid)
end

function pixelToGrid(x,y,grid)
	local xoff = (love.graphics.getWidth()%grid)/2+grid/2
	local yoff = (love.graphics.getHeight()%grid)/2+grid/2
	return math.floor(x/grid-0.5)*grid+xoff, math.floor(y/grid-0.5)*grid+yoff
end

function cellToGrid(x,y,grid)
	local xoff = (love.graphics.getWidth()%grid)/2+grid/2
	local yoff = (love.graphics.getHeight()%grid)/2+grid/2
	return xoff+x*grid,yoff+y*grid
end


function doWindow(x,y,w,h,ui)

	local grid = ui.grid

	local w = w*grid
	local h = h*grid
	local t = grid/4
	local f = love.graphics.getFont()
	local x, y = cellToGrid(x,y,grid)

	x = x+0.5
	y = y+0.5

	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(3,13,23,32)
	love.graphics.rectangle("fill",x,y,w,h)


	love.graphics.setColor(128,196,255,128)


	love.graphics.line(x,y,x+5,y)
	love.graphics.line(x,y,x,y+5)

	love.graphics.line(x+w,y,x+w-4,y)
	love.graphics.line(x+w,y,x+w,y+5)

	love.graphics.line(x,y+h,x+5,y+h)
	love.graphics.line(x,y+h,x,y+h-4)

	love.graphics.line(x+w,y+h,x+w-4,y+h)
	love.graphics.line(x+w,y+h,x+w,y+h-4)

	love.graphics.line(x,y+t,x+5,y+t)
	love.graphics.line(x,y+t,x,y+t-4)

	love.graphics.line(x+w,y+t,x+w-4,y+t)
	love.graphics.line(x+w,y+t,x+w,y+t-4)
	local msg = "tty"..ui.wid
	ui.wid = ui.wid+1
	local fyo = f:getHeight(msg)
	local fxo = f:getWidth(msg)
	local fx = math.floor(x+w/2-fxo/2)
	local fy = math.floor(y+t/2-fyo/2)
	love.graphics.print(msg,fx,fy)


end


function doPatches()
	local r,g,b,a = love.graphics.getColor()
	local grid = 128
	local xoff = (love.graphics.getWidth()%grid)/2+grid/2
	local yoff = (love.graphics.getHeight()%grid)/2+grid/2
	love.graphics.setLineStyle("rough")
	for i=xoff,love.graphics.getWidth()-grid,grid do
		for j=yoff,love.graphics.getHeight()-grid,grid do
			local x = math.floor(i)+0.5
			local y = math.floor(j)+0.5
			love.graphics.setColor(255,255,255,60)
			love.graphics.print("t-"..math.floor(love.math.noise(x-0.5,y-0.5)*100)/100,x+5.5,y+5.5)
			love.graphics.setColor(
				255,255,255,
				2+(math.sin(love.math.noise(x-0.5,y-0.5)*math.pi*2+love.timer.getTime()*love.math.noise(x+0.5,y+0.5)*0.2)*2)
				)
			love.graphics.rectangle("fill",x,y,grid,grid)
		end
	end
	love.graphics.setColor(r,g,b,a)
end

function doGrid(grid)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(255,255,255,3)
	local mode = love.graphics.getBlendMode()
	love.graphics.setBlendMode("add")
	local xoff = (love.graphics.getWidth()%grid)/2+grid/2
	local yoff = (love.graphics.getHeight()%grid)/2+grid/2
	love.graphics.setLineStyle("rough")
	for i=xoff,love.graphics.getWidth(),grid do
		for j=yoff,love.graphics.getHeight(),grid do
			local x = math.floor(i)+0.5
			local y = math.floor(j)+0.5
			--[[
			love.graphics.points(
				x,y,
				x+1,y,
				x,y+1,
				x-1,y,
				x,y-1
				)
			--]]
			love.graphics.line(x-3,y,x+4,y)
			love.graphics.line(x,y-3,x,y+4)
		end
	end
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(3,13,23,64)
	fromToRect("fill",0,0,love.graphics.getWidth(),yoff)
	fromToRect("fill",0,love.graphics.getHeight(),love.graphics.getWidth(),love.graphics.getHeight()-yoff+1)
	fromToRect("fill",0,yoff,xoff,love.graphics.getHeight()-yoff+1)
	fromToRect("fill",love.graphics.getWidth(),yoff,love.graphics.getWidth()-xoff+1,love.graphics.getHeight()-yoff+1)

	love.graphics.setColor(r,g,b,a)
	love.graphics.setBlendMode(mode)

end

function fromToRect(mode,x1,y1,x2,y2)
	love.graphics.rectangle(mode,x1,y1,x2-x1,y2-y1)
end