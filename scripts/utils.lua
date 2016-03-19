--- A couple functions to make things easier
-- @submodule Hex

--- Check if a value is between two others.  Parameters need not be in ascending order.
-- @tparam number x The value to compare with the other two
-- @tparam number first The first value (could be lower or upper bound)
-- @tparam number second The second value (could be lower or upper bound)
function math.between(x, first, second)
	return x >= first and x <= second or x <= first and x >= second
end

--- Returns the sign of a given number
-- @tparam number x The number whose sign we will check
-- @treturn number -1 if x < 0, 1 if x > 0, or 0 if x is 0
function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end
