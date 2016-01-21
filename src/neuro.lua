local neuro_mt = {}
neuro = {}

function neuro.size(ins, outs, nLayers, perLayer)
	return perLayer * ins + (nLayers-1) * perLayer + outs * perLayer
end

function neuro.new(ins, outs, nLayers, perLayer, values)
	local self = setmetatable({},{__index=neuro_mt})

	ins = ins+1

	self.values = values or {}
	local dValues = {}
	self.nLayers = nLayers
	self.perLayer = perLayer

	local _i = 1
	local _next = function()
		_i = _i+1
		table.insert(dValues,values and values[_i] or math.random()*2-1)
		return dValues[#dValues]
	end

	self.ins = {}
	for i=1,ins do
		table.insert(self.ins, 0)
	end
	self.outs = {}
	for i=1,outs do
		table.insert(self.outs, 0)
	end
	self.layers = {}
	for l=1,nLayers do
		self.layers[l] = {}
		for d=1,perLayer do
			self.layers[l][d] = {}
			for a=1,(l==1 and ins or perLayer) do
				self.layers[l][d][a] = _next()
			end
		end
	end
	self.layers[nLayers+1] = {}
	for d=1,outs do
		self.layers[nLayers+1][d] = {}
		for a=1,perLayer do
			self.layers[nLayers+1][d][a] = _next()
		end
	end
	self.memo = {}
	return self, dValues
end

function neuro_mt:update()
	self.memo = {}
	self.ins[#self.ins] = 1
	for i,v in ipairs(self.outs) do
		self.outs[i] = self:getVal(#self.layers,i)
	end
end

function neuro.color(v)
	return (v<0 and math.abs(v)*255 or 0), 0, (v>0 and v*255 or 0)
end

function neuro_mt:draw(x,y,size,space)
	local x = x or 10
	local y = y or 10
	local size = size or 20
	local space = space or 10
	for i=1,#self.ins do
		local r,g,b = neuro.color(self.ins[i])
		love.graphics.setColor(r,g,b,255)
		love.graphics.rectangle("fill", x, y+i*(size+space), size, size)
	end
	for i=1,self.nLayers do
		for j=1,self.perLayer do
			local r,g,b = neuro.color(self:getVal(i,j))
			love.graphics.setColor(r,g,b,255)
			love.graphics.rectangle("fill", x + i*(size+space), y+j*(size+space), size, size)
		end
	end
	for i=1,#self.outs do
		local r,g,b = neuro.color(self.outs[i])
		if self.outs[i]>0.5 then
			love.graphics.setColor(0,255,255)
		else
			love.graphics.setColor(r,g,b,255)
		end
		love.graphics.rectangle("fill", self.nLayers*(size+space)+x+size+space, y+i*(size+space), size, size)
	end
end

function neuro_mt:getVal(l,n)
	if l==0 then
		return self.ins[n]
	elseif self.memo[l.."-"..n] then
		return self.memo[l.."-"..n]
	else
		local mults = self.layers[l][n]
		local vals = {}
		for i,a in ipairs(mults) do
			vals[i] = neuro.scaler(self:getVal(l-1,i),a)
		end
		self.memo[l.."-"..n] = neuro.mixer(vals)
		return self.memo[l.."-"..n]
	end
end

function neuro_mt:getMult(l,n)
	return self.layers[l][n]
end

function neuro.scaler(v,a)
	return math.sinh(a*v)
	--return a*v
	--return a*math.sqrt(math.abs(v))*(v>=0 and 1 or -1)
end

function neuro.mixer(vs)
	local sum = 0
	for i,v in ipairs(vs) do
		sum = sum+(v)
	end
	return math.tanh(sum)
end


--[[

local values = {}
for i=1,55 do--neuro.size(3,3,2,5) do
	values[i] = math.random()*2-1
end
local net = neuro.new(3,3,5,8,values)
for i=1,3 do
	net.ins[i] = math.random(0,1)*2-1
end
net:update()
print("Ins:")
for i,v in ipairs(net.ins) do
	print("in "..i.." = "..v)
end
print("Outs:")
for i,v in ipairs(net.outs) do
	print("out: "..i.." = "..(v>0 and 1 or -1))
end

--]]