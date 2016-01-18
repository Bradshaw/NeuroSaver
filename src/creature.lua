local creature_mt = {}
creature = {}
creature.all = {}

function creature.new()
	local self = setmetatable({},{__index=creature_mt})

	

	table.insert(creature.all,self)
	return self
end

function creature.update(dt)
	for i,v in useful.upairs() do
		v:update(dt)
	end
end

function creature.draw()
	for i,v in ipairs(table_name) do
		v:draw()
	end
end

function creature_mt:update(dt)
	
end

function creature_mt:draw()
	
end