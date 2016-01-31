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

function Entities:getAtPoint(x, y)
	x, y = Camera:worldCoords(x, y)
	for _, entity in pairs(self.pool) do
		if entity:checkCollision(x, y) then
			return entity
		end
	end
end

function Entities:pointerdown(x, y)
	x, y = Camera:worldCoords(x, y)
	for _, entity in pairs(self.pool) do
		entity:pointerdown(x, y, dx, dy)
	end
end

function Entities:pointermoved(x, y, dx, dy)
	x, y = Camera:worldCoords(x, y)
	for _, entity in pairs(self.pool) do
		entity:pointermoved(x, y, dx, dy)
	end
end

function Entities:pointerreleased(x, y)
	x, y = Camera:worldCoords(x, y)
	
	for _, entity in pairs(self.pool) do
		entity:pointerreleased(x, y)
	end
end

function Entities:forEach(func)
	for _, entity in pairs(self.pool) do
		func(entity)
	end
end

return Entities