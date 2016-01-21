local spaceship_mt = {}
spaceship = {}

spaceship.all = {}

function spaceship.new(x,y,typo)
	local self = setmetatable({},{__index=spaceship_mt})
	local typo = typo
	local dValues

	self.phys = {}
	self.phys.body = love.physics.newBody(world,
		x or love.graphics.getWidth()*math.random(),
		y or love.graphics.getHeight()*math.random(),
		"dynamic")
	self.phys.shape = love.physics.newCircleShape(10)
	self.phys.fixture = love.physics.newFixture(self.phys.body, self.phys.shape)
	self.phys.body:setLinearDamping(1)
	self.phys.body:setAngularDamping(2)

	if typo then
		self.name = typo.name
		self.thrusters = typo.thrusters
		self.sensors = typo.sensors
		self.net, dValues = neuro.new(#self.sensors+3,#self.thrusters,15,8, typo.dValues)
	else
		self.name = useful.randomString(6)
		self.thrusters = {}
		self.sensors =  {}
		local ts = math.random(2,5)
		for i=1,ts do
			local pa = math.random()*math.pi*2
			local aa = math.random()*math.pi-math.pi/2
			self:addThruster(pa,aa)
		end
		for i=1,7-ts do
			self:addSensor(math.random()*math.pi*2,math.random())
		end

		self.net, dValues = neuro.new(8,5,15,8)
	end
	typo = {}
	typo.name = self.name
	typo.thrusters = self.thrusters
	typo.sensors = self.sensors
	typo.dValues = dValues


	table.insert(spaceship.all, self)
	return self, typo
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

function spaceship.mutate(typo)
	local t = {}
	t.dValues = {}
	for i,v in ipairs(typo.dValues) do
		t.dValues[i] = v + useful.nrandom(0.01)
	end
	t.thrusters = {}
	for i,v in ipairs(typo.thrusters) do
		local pa, aa = v.pa, v.aa
		pa = pa+useful.nrandom(0.05)
		aa = math.min(math.pi/2, math.max(-math.pi/2,aa+useful.nrandom(0.01)))
		local x,y,a = math.cos(pa)*10,math.sin(pa)*10,pa+aa
		t.thrusters[i] = {
			pa = pa,
		aa = aa,
		x = x,
		y = y,
		a = a
		}
	end
	t.sensors = {}
	for i,v in ipairs(typo.sensors) do
		local a, rr = v.a, v.rr
		a = a+useful.nrandom(0.05)
		rr = math.max(0,math.min(1,rr+useful.nrandom(0.01)))
		local minRadius = 100
		local maxRadius = 600
		local maxAngle = math.pi
		local minAngle = math.pi/50
		t.sensors[i] = {
			a = a,
			rr = rr,
			a1 = a+useful.lerp(maxAngle,minAngle,rr)/2,
			a2 = a-useful.lerp(maxAngle,minAngle,rr)/2,
			r = useful.lerp(minRadius,maxRadius,rr*rr*rr)
		}
	end
	local e = math.random(1,typo.name:len())
	t.name = typo.name:sub(1,e-1)..string.char(math.random(33,126))..typo.name:sub(e+1)
	return t
end

function spaceship.splice(a,b)
	local t = {}
	t.thrusters = {}
	for i,v in ipairs(a.thrusters) do
		t.thrusters[i] = {
			pa = v.pa,
			aa = v.aa,
			x = v.x,
			y = v.y,
			a = v.a
		}
	end
	t.sensors = {}
	for i,v in ipairs(a.sensors) do
		t.sensors[i] = {
			a = v.a,
			rr = v.rr,
			a1 = v.a1,
			a2 = v.a2,
			r = v.r
		}
	end
	local e = math.random()
	local ed = math.floor(e*#a.dValues)
	t.dValues = {}
	for i=1,ed do
		t.dValues[i] = a.dValues[i]
	end
	for i=ed+1,#b.dValues do
		t.dValues[i] = b.dValues[i]
	end
	local es = math.floor(e*a.name:len())
	t.name = a.name:sub(1,es)..b.name:sub(es+1)
	return t
end

function spaceship_mt:addThruster(pa,aa)
	local x,y,a = math.cos(pa)*10,math.sin(pa)*10,pa+aa
	table.insert(self.thrusters,{
		pa = pa,
		aa = aa,
		x = x,
		y = y,
		a = a
	})
end

function spaceship_mt:addSensor(a,rr)
	local minRadius = 100
	local maxRadius = 600
	local maxAngle = math.pi
	local minAngle = math.pi/50
	table.insert(self.sensors,{
		a = a,
		rr = rr,
		a1 = a+useful.lerp(maxAngle,minAngle,rr)/2,
		a2 = a-useful.lerp(maxAngle,minAngle,rr)/2,
		r = useful.lerp(minRadius,maxRadius,rr*rr*rr)
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
	local lx = math.cos(-a)*vx - math.sin(-a)*vy
	local ly = math.sin(-a)*vx + math.cos(-a)*vy
	for i,v in ipairs(self.sensors) do
		self.net.ins[i] = self:sense(i)
	end
	self.net.ins[#self.sensors+1] = va/12
	self.net.ins[#self.sensors+2] = lx/60
	self.net.ins[#self.sensors+3] = ly/60
	self.net:update()
	
	for i=1,math.min(#self.thrusters,#self.net.outs) do
		self.thrusters[i].burn = false
		if (self.net.outs[i]>0.5) then
			self:activateThruster(i)
		end
	end

end

function spaceship_mt:drawFixedUI()
	--self:drawUnfettered(200,200,0)
end

function spaceship_mt:drawOverlayUI()
	local x, y = self.phys.body:getPosition()
	love.graphics.setColor(127,127,127)
	love.graphics.line(x+20,y-20,x+50,y-50,x+50+font:getWidth(self.name),y-50)
	--love.graphics.rectangle("line", x-20.5, y-20.5, 40, 40)
	love.graphics.setColor(255,255,255)
	local fh = font:getHeight()
	love.graphics.print(self.name, x+50,y-50-fh)
	love.graphics.print("Sensors: "..#self.sensors, x+50,y-50+fh*0)
	love.graphics.print("Thrusters: "..#self.thrusters, x+50,y-50+fh*1)
	self.net:draw(x+50,y-50+fh*2,4,2)
end

function spaceship_mt:draw()
	local x, y = self.phys.body:getPosition()
	local a = self.phys.body:getAngle()
	self:drawUnfettered(x,y,a)
end

function spaceship_mt:drawUnfettered(x,y,a)
	local vx, vy = self.phys.body:getLinearVelocity()
	local r,g,b = neuro.color(self.net.outs[1])
	local ang = self.phys.body:getAngle()
	local lx = math.cos(-ang)*vx - math.sin(-ang)*vy
	local ly = math.sin(-ang)*vx + math.cos(-ang)*vy
	local dlx = math.cos(a)*lx - math.sin(a)*ly
	local dly = math.sin(a)*lx + math.cos(a)*ly
	love.graphics.setColor(0,255,255)
	love.graphics.line(x,y,x+dlx,y+dly)
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
		local s = self.net.ins[i]
		local r = s>0 and useful.lerp(255,0,math.abs(s)) or 255
		local b = s<0 and useful.lerp(255,0,math.abs(s)) or 255
		local g = useful.lerp(255,0,math.abs(s))
		local al = useful.lerp(2,4,math.abs(s))
		love.graphics.setColor(r,g,b,al)
		love.graphics.arc("fill", x, y, v.r, v.a1+a, v.a2+a)
	end

	--love.graphics.line(x,y,x+self.net.outs[1]*40,y+self.net.outs[2]*40)
	--love.graphics.line(x,y,x+vx,y+vy)
end

