function testScreenCollision(x,y,ox,oy,w,h)
	posx = x - ox;
	posy = y - oy;
	--checking x
	if(posx <= 0) then
		posx = 0;
	else
		if(posx + w >= love.graphics.getWidth()) then
			posx = love.graphics.getWidth() - w;
		end
	end

	--checking y
	if(posy <=0) then
		posy = 0;
	else
		if(posy + h >= love.graphics.getHeight()) then
			posy = love.graphics.getHeight() - h;
		end
	end

	x = posx + ox;
	y = posy + oy;
	return x,y;
end

function CalculateImpulse(rotSpeed,mass,x1,y1,x2,y2)
	if(rotSpeed == nil) then rotSpeed = HIT; end
	local cx,cy; --change in x and y coordinates
	cx = x2-x1;
	cy = y2-y1;
	return (cx * rotSpeed * mass*HITMOD),(cy * rotSpeed * mass*HITMOD)
end