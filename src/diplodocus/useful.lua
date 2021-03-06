local useful = {}
local ID = 0
useful.tau = math.pi*2

function useful.getNumID()
	ID = ID+1
	return ID
end

function useful.getStrID()
	return string.format("%06d",useful.getNumID())
end

function useful.randomString(length)
	local str = ""
	while str:len()<length do
		str = str..string.char(math.random(33,126))
	end
	return str
end

local default_upairs_test = function(elem)
	return (type(elem)=="table") and (elem.purge) or false
end

function useful.upairs(t, test)
	local index = 1
	local iterator
	iterator = function(t)
		if index>#t then
			return nil
		else
			if (test or default_upairs_test)(t[index]) then
				table.remove(t, index)
				return iterator(t)
			else
				index = index+1
				return index-1, t[index-1]
			end
		end
	end
	return iterator, t
end

function useful.lerp( a, b, n )
	return n*b+(1-n)*a
end

function useful.moveTowards2D(a,b,n)
	local dx = b.x-a.x
	local dy = b.y-a.y
	local d = math.sqrt(dx*dx+dy*dy)
	local dist = math.min(n,d)
	if d>0 then
		local nx = dx/d
		local ny = dy/d
		return a.x + dist * nx, a.y + dist * ny
	end
	return a.x,a.y
end

function useful.dist2( x1, y1, x2, y2 )
	if type(x1)=="table" then
		return useful.dist2(x1.x, x1.y, y1.x, y1.y)
	end
	if x2 then
		return useful.dist2(x2-x1, y2-y1)
	else
		return (x1*x1 + y1*y1)
	end
end

function useful.dead(n, zone)
	local zone = zone or 0.3
	return math.abs(n)>zone and n or 0
end

function useful.xyDead(x, y, options)
	local options = options or {}
	local zone = options.zone or 0.3
	local mode = options.mode or "rescaled"
	if useful.dist2(x,y)>zone*zone then
		if mode=="simple" then
			return x, y
		else
			local d = useful.dist(x,y)
			local nx = x/d
			local ny = y/d
			if mode=="rescaled" then
				local dd = (d-zone)/(1-zone)
				return nx*dd,ny*dd
			elseif mode=="digital" then
				return nx, ny
			end
		end
	else
		return 0,0
	end
end

function useful.dist(...)
	return math.sqrt(useful.dist2(...))
end

function useful.nrandom(sigma, mu)
	local sigma = sigma or 1
	local mu = mu or 0
	local u1 = math.random()
	local u2 = math.random()
	local z0 = math.sqrt(-2*math.log(u1)) * math.cos(useful.tau * u2)
	return z0 * sigma + mu
end

function useful.orandom(probability, multiplier)
	local probability = probability or 0.1
	local multiplier = multiplier or 10
	return math.random()*(math.random()<probability and multiplier or 1)
end

--[[
	Iterates a function into itself

	To achieve f(f(f(a, b, c))) do useful.iterate(f, 3, a, b, c)

	Ideally the iterated function should return as many value as it has parameters, and in a semantically identical order.
]]
function useful.iterate(fn, it, ...)
	if it>1 then
		return fn(useful.iterate(fn, it-1, ...))
	else
		return fn(...)
	end
end


function useful.sum(a, ...)
	if (a) then
		return a + useful.sum(...)
	else
		return 0
	end
end

return useful