function between(x, first, second)
	return x >= first and x <= second or x <= first and x >= second
end

function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end
