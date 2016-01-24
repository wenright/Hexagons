local Entities = Class {
	init = function(self, class)
		self.type = class.type
		self.class = class

		self.pool = {}
	end,

	type = 'entitysystem'
}

function Entities:add(...)
	table.insert(self.pool, self.class(...))
end

function Entities:remove(obj)
	for key, entity in ipairs(self.pool) do
		if entity == obj then
			self.pool[key] = nil
			break
		end
	end
end

function Entities:update(dt)
	for _, entity in ipairs(self.pool) do
		entity:draw()
	end
end

function Entities:draw()
	for _, entity in ipairs(self.pool) do
		entity:draw()
	end
end

return Entities