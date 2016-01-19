local spaceship_mt = {}
spaceship = {}

spaceship.all = {}

function spaceship.new(x,y)
	local self = setmetatable({},{__index=spaceship_mt})

	self.thrusters = {}
	self.sensors = {}

	self.phys = {}
	self.phys.body = love.physics.newBody(world,
		x or love.graphics.getWidth()*math.random(),
		y or love.graphics.getHeight()*math.random(),
		"dynamic")
	self.phys.shape = love.physics.newCircleShape(10)
	self.phys.fixture = love.physics.newFixture(self.phys.body, self.phys.shape)
	self.phys.body:setLinearDamping(1)
	self.phys.body:setAngularDamping(2)
	table.insert(spaceship.all, self)
	---[[
	local ts = math.random(2,5)
	for i=1,ts do
		local pa = math.random()*math.pi*2
		local aa = math.random()*math.pi-math.pi/2
		self:addThruster(math.cos(pa)*10,math.sin(pa)*10,pa+aa)
	end
	--]]
	--[[
	self:addThruster(10,0,0)
	self:addThruster(0,10,0)
	self:addThruster(0,-10,0)
	--]]

	for i=1,7-ts do
		self:addSensor(math.random()*math.pi*2,math.random())
	end

	self.max = {
		vx = 0,
		vy = 0,
		va = 0
	}

	self.net = neuro.new(#self.sensors+3,#self.thrusters,10,8)

	return self
end

function spaceship.update(dt)
	for i, v in useful.upairs(spaceship.all) do
		v:update(dt)
	end
end

function spaceship.draw()
	for i,v in ipairs(spaceship.all) do
		v:draw()
	end
end

function spaceship_mt:addThruster(x,y,a)
	table.insert(self.thrusters,{
		x = x,
		y = y,
		a = a
	})
end

function spaceship_mt:addSensor(a,r)
	local minRadius = 50
	local maxRadius = 300
	local maxAngle = math.pi
	local minAngle = math.pi/50
	table.insert(self.sensors,{
		a1 = a+useful.lerp(maxAngle,minAngle,r)/2,
		a2 = a-useful.lerp(maxAngle,minAngle,r)/2,
		r = useful.lerp(minRadius,maxRadius,r*r*r)
	})
end

function spaceship_mt:activateThruster(t)
	local thruster = self.thrusters[t]
	local x, y = self.phys.body:getPosition()
	local a = self.phys.body:getAngle()
	local tx = x + math.cos(a)*thruster.x - math.sin(a)*thruster.y
	local ty = y + math.sin(a)*thruster.x + math.cos(a)*thruster.y
	self.phys.body:applyForce(
		-5*math.cos(a+thruster.a),
		-5*math.sin(a+thruster.a),
		tx,ty
		)
	thruster.burn = true
end

function spaceship_mt:sense(s)
	local sensor = self.sensors[s]
	local a1 = sensor.a1+self.phys.body:getAngle()
	local a2 = sensor.a2+self.phys.body:getAngle()
	local x, y = self.phys.body:getPosition()
	local closest
	local sensedFood = false
	---[[
	for i,v in ipairs(spaceship.all) do
		if self~=v then
			local vx, vy = v.phys.body:getPosition()
			local d2 = useful.dist2(x,y,vx,vy)
			local dx = x-vx
			local dy = y-vy
			if d2<sensor.r*sensor.r and isInArc(a1,a2,sensor.r,dx,dy) then
				closest = math.min((closest or math.huge),d2)
			end
		end
	end
	for i,v in ipairs(food) do
		local vx, vy = v.x, v.y
		local d2 = useful.dist2(x,y,vx,vy)
		local dx = x-vx
		local dy = y-vy
		if d2<sensor.r*sensor.r and isInArc(a1,a2,sensor.r,dx,dy) then
			sensedFood = true
			closest = math.min((closest or math.huge),d2)
		end
	end
	--]]
	if closest then
		return (1-(math.sqrt(closest)/sensor.r)) * (sensedFood and -1 or 1)
	else
		return 0
	end
end

function isInArc(a1,a2,r,x,y)
	--local d = math.sqrt(x*x+y*y)
	local a1x = math.cos(a1)
	local a1y = math.sin(a1)
	local a2x = math.cos(a2)
	local a2y = math.sin(a2)
	local c1 = a1x * y - a1y * x
	local c2 = x * a2y - y * a2x
	return c1>0 and c2>0
end

function spaceship_mt:update(dt)
	local x, y = self.phys.body:getPosition()
	local a = self.phys.body:getAngle()
	local vx, vy = self.phys.body:getLinearVelocity()
	local va = self.phys.body:getAngularVelocity()
	local lx = math.cos(a)*vx - math.sin(a)*vy
	local ly = math.sin(a)*vx + math.cos(a)*vy
	for i,v in ipairs(self.sensors) do
		self.net.ins[i] = self:sense(i)
	end
	self.net.ins[#self.sensors+1] = va/6
	self.net.ins[#self.sensors+2] = lx/30
	self.net.ins[#self.sensors+3] = ly/30
	self.net:update()
	
	for i=1,math.min(#self.thrusters,#self.net.outs) do
		self.thrusters[i].burn = false
		if (self.net.outs[i]>0.5) then
			self:activateThruster(i)
		end
	end

end

function spaceship_mt:draw()
	local x, y = self.phys.body:getPosition()
	local vx, vy = self.phys.body:getLinearVelocity()
	local a = self.phys.body:getAngle()
	local r,g,b = neuro.color(self.net.outs[1])
	love.graphics.setColor(255,255,255)
	love.graphics.circle("line", x, y, 10)
	--love.graphics.line(x+math.cos(a)*10,y+math.sin(a)*10,x+math.cos(a)*15,y+math.sin(a)*15)
	for i,v in ipairs(self.thrusters) do
		if v.burn then
			love.graphics.setColor(255,255,255)
		else
			love.graphics.setColor(127,127,127)
		end
		local tx = x + math.cos(a)*v.x - math.sin(a)*v.y
		local ty = y + math.sin(a)*v.x + math.cos(a)*v.y
		love.graphics.line(tx,ty,tx+math.cos(a+v.a)*15,ty+math.sin(a+v.a)*15)
	end

	for i,v in ipairs(self.sensors) do
		love.graphics.setColor(127,127,127)
		love.graphics.arc("line", x, y, v.r, v.a1+a, v.a2+a)
	end

	--love.graphics.line(x,y,x+self.net.outs[1]*40,y+self.net.outs[2]*40)
	--love.graphics.line(x,y,x+vx,y+vy)
end

