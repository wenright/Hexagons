local Entities = Class {
	init = function(self, class)
		self.type = class.type
		self.class = class

		self.pool = {}
	end,

	type = 'entitysystem'
}

function Entities:add(...)
	local obj = self.class(...)
	table.insert(self.pool, obj)
	return obj
end

function Entities:update(dt)
	for _, entity in pairs(self.pool) do
		entity:update(dt)
	end
end

function Entities:draw()
	for _, entity in pairs(self.pool) do
		entity:draw()
	end
end

function Entities:pointermoved(x, y, dx, dy)
	for _, entity in pairs(self.pool) do
		entity:pointermoved(x, y, dx, dy)
	end
end

function Entities:pointerreleased()
	for _, entity in pairs(self.pool) do
		entity:pointerreleased()
	end
end

return Entities