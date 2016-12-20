--- A collection of entities
-- @classmod Entities

local Entities = Class {
	type = 'entitysystem'
}

--- Initialize a new Entities object
-- @tparam Class class The class of object that will occupy the entity system
function Entities:init(class)
  self.type = class.type
  self.class = class

  self.pool = {}
end

--- Add a new entity to the system
-- @param ... The parameters that will be passed into the newly created object using the class from init
-- @return The object that was created and added
function Entities:add(...)
	local obj = self.class(...)
	table.insert(self.pool, obj)
	return obj
end

--- Remove an entity from the system
-- @param e The entity to remove
function Entities:remove(e)
	for key, entity in pairs(self.pool) do
		if entity == e then
			self.pool[key] = nil
		end
	end
end

--- Draw all entities in the system
function Entities:draw()
	for _, entity in pairs(self.pool) do
		entity:draw()
	end
end

--- Find the entity at the given point
-- @tparam number x The x coordinate to check
-- @tparam number y The y coordinate to check
-- @treturn Class The object at the given location, if there is one
function Entities:getAtPoint(x, y)
	-- TODO Maybe select the closest hex instead of the one directly under cursor
	x, y = Camera:worldCoords(x, y)
	for _, entity in pairs(self.pool) do
		if entity:checkCollision(x, y) then
			return entity
		end
	end
end

--- Loop over each object, calling the given function on each entity
-- @tparam function func The function that will be called for each entity
function Entities:forEach(func)
	for _, entity in pairs(self.pool) do
		func(entity)
	end
end

return Entities
