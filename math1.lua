function abs(n)
	if n == nil then
		--probably
		JOYDISCONNECTED = true
		return 0
	elseif n < 0 then
			return -n
	else
		return n
	end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

--Finds tan between two points
function math.angle(x1, y1, x2, y2)
	return math.rad(math.atan2(y2 - y1, x2 - x1) * (180 / math.pi) + 90)
end

--Finds distance between 2 points
function math.distance(x1, y1, x2, y2)
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

--Finds distance between 2 points
function math.distance(x, y)
	return math.sqrt(math.pow(x, 2) + math.pow(y, 2))
end

function math.vectorAbs(x, y)
	return math.distance(x, y)
end

function lerp(from, to, t)
  return t < 0.5 and from + (to-from)*t or to + (from-to)*(1-t)
end

function ease_function(t)
	return (1-math.cos(t*math.pi))/2
end
