function abs(n)
	if(n==nil) then
		--probably
		JOYDISCONNECTED = true;
		return 0;
	else
		if(n<0) then
			n = -n;
		end
		return n;
	end
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1)* (180/math.pi) + 90 end

function math.distance(x1,y1,x2,y2) return math.sqrt(math.pow(x2- x1,2) + math.pow(y2-y1,2)) end
