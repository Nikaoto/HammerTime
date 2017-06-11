--require("main");
function CheckJoyCompatibility()
		for i=1,4 do
			if not(joysticks[i] == nil) then
				if(joysticks[i]:getAxisCount() > 3) then
					if(joysticks[i]:getButtonCount() >2) then
						compatibleJoyCount = compatibleJoyCount + 1;
					else
						print("joystick Number" .. i .. "is incompatible");
					end
				else
					print("joystick Number" .. i .. "is incompatible");
				end
			end
		end
end

function love.joystickpressed(joy,butt)
	--PLAYER1 JOYSTICK
		if (joy == joysticks[1]) then
			if (butt == player1.controller.SWING) then
				if(player1.csp >=SWINGCOST) then
					player1.hammer.isSwinging = true;
				else
					player1.hammer.isSwinging = false;
				end
				player1.speed = SWING_MOVESPEED;
			end
			if(butt == player1.controller.PAUSE) then
				PAUSEDBY = "Player 1";
				PAUSED = not PAUSED;
			end
		end
	--END OF PLAYER1
	--PLAYER2 JOYSTICK
		if (joy == joysticks[2]) then
			if(butt==player2.controller.SWING) then
				if(player2.csp >=SWINGCOST) then
					player2.hammer.isSwinging = true;
				end
				player2.speed = SWING_MOVESPEED;
			end
			if(butt == player2.controller.PAUSE) then
				PAUSEDBY = "Player 2";
				PAUSED = not PAUSED;
			end
		end
	--END OF PLAYER2
	--PLAYER3 JOYSTICK
		if (joy == joysticks[3]) then
			if(butt==player3.controller.SWING) then
				if(player3.csp >=SWINGCOST) then
					player3.hammer.isSwinging = true;
				end
				player3.speed = SWING_MOVESPEED;
			end
			if(butt == player3.controller.PAUSE) then
				PAUSEDBY = "Player 3";
				PAUSED = not PAUSED;
			end
		end
	--END OF PLAYER3
end

function love.joystickreleased(joy,butt)
	--PLAYER1 JOYSTICK
		if(joy == joysticks[1]) then
			if (butt == player1.controller.SWING) then
				player1.hammer.isSwinging = false;
				player1.speed = MOVESPEED;
			end
		end
	--END OF PLAYER1
	--PLAYER2 JOYSTICK
		if(joy == joysticks[2]) then
			if(butt == player2.controller.SWING) then
				player2.hammer.isSwinging = false;
				player2.speed = MOVESPEED;
			end
		end
	--END OF PLAYER2
	--PLAYER3 JOYSTICK
		if(joy == joysticks[3]) then
			if(butt == player3.controller.SWING) then
				player3.hammer.isSwinging = false;
				player3.speed = MOVESPEED;
			end
		end
	--END OF PLAYER3
end

function love.joystickadded(joy)
	--CHECKING JOYSTICK COMPATIBILITY
		newJoy = true;
		for i=1,4 do
			if (joy == joysticks[i]) then
				JOYDISCONNECTED = false;
				newJoy = false;
			end
		end
		if(newJoy) then
			if(joy:getAxisCount() > 3) then
				if(joy:getButtonCount() >1) then
					compatibleJoyCount = compatibleJoyCount + 1;
					joysticks[compatibleJoyCount] = joy;
					if(compatibleJoyCount ==1) then createP1(); end  --add player1
					if (compatibleJoyCount == 2) then createP2(); end --add player2
					if (compatibleJoyCount == 3) then createP2(); end --add player3
				else
					print("joystick Number" .. compatibleJoyCount+1 .. "is incompatible");
				end
			else
				print("joystick Number" .. compatibleJoyCount+1 .. "is incompatible");
			end
		end
	--END OF JOY COMPATIBILITY CHECK
end

function love.joystickremoved(joy)
	if (joy == player1.controller.joystick) or (joy == player2.controller.joystick) or (joy == player3.controller.joystick) then
		JOYDISCONNECTED = true;
		PAUSED = true;
		if(joy == player1.controller.joystick) then PAUSEDBY = "Player 1"; end
		if(joy == player2.controller.joystick) then PAUSEDBY = "Player 2"; end
		if(joy == player3.controller.joystick) then PAUSEDBY = "Player 3"; end
	end
end

function CheckDeadzone(xa,ya,deadzone)
	if (abs(xa) > deadzone) or (abs(ya) > deadzone) then
		return true
	else
		return false
	end
end
