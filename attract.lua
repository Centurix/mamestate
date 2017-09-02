#!/usr/bin/lua

local STATE_FOLDER = "/emulators/mame/scripts/states"
local SERIAL_DEVICE = "/dev/ttyACM0"
local BAUD_RATE = "9600"

local CHATTER_CMD = "/emulators/mame/scripts/chatter.py"

local MODE_ONE_PLAYER = "mode_one_player\n"
local MODE_MORE_PLAYERS = "mode_more_players\n"
local MODE_NO_COINS = "mode_no_coins\n"
local MODE_GAME_PLAY = "mode_game_play\n"
local MODE_ATTRACT = "mode_attract\n"
local MODE_GAME_OVER = "mode_game_over\n"
local MODE_HISCORE = "mode_hiscore"

local wserial
local last_tick_time = -10
local current_playing = false
local current_players = -1
local current_coins = 0
local last_score = 0

local state_filename = STATE_FOLDER .. "/" .. emu.romname() .. ".lua"

function write_serial(message)
	wserial:write(message)
	wserial:flush()
end

-- Let's check state!
function tick()
	if emu.time() < last_tick_time + 1 then
		return
	end
	last_tick_time = emu.time()
	
	local coins = game:coins()
	if coins ~= current_coins then
		if coins == 0 then
			print("MODE: No coins")
			write_serial(MODE_NO_COINS)
		elseif coins == 1 then
			print("MODE: One player")
			write_serial(MODE_ONE_PLAYER)
		else
			print("MODE: More players")
			write_serial(MODE_MORE_PLAYERS)
		end
		current_coins = coins
	end

	local playing = game:playing()
	if playing ~= current_playing then
		if playing then
			print("MODE: Game play")
			write_serial(MODE_GAME_PLAY)
		else
			print("MODE: Game over")
			write_serial(MODE_GAME_OVER)
		end
		current_playing = playing
	end

	-- CURRENT WORK:
	-- So far the following games work for hiscores:
	-- 
	-- * BombJack
	-- * Puckman
	-- * Bagman
	-- 
	-- This below will change mode to MODE_HISCORE
	-- Need to add hi score mode to the Arduino
	local hiscore = game:hiscore()
	if last_score < game:score() and last_score < hiscore and game:score() > 0 then
	-- if last_score < game:score() and last_score < hiscore and game:score() > hiscore then
		print("MODE: Beaten high score")
		write_serial(MODE_HISCORE .. game:score() .. "\n")
	end
end

-- Always send the marquee if we can
-- Pass the binary upload control to Python, it has built in PNG and serial support

-- Quick reset of the Arduino, set DTR high
os.execute("stty -F /dev/ttyACM0 " .. BAUD_RATE .. " time 0 hupcl -brkint -icrnl -imaxbel -opost -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke")
wserial = io.open(SERIAL_DEVICE, "w+b")
wserial:write(MODE_ATTRACT)
wserial:close()

os.execute("python " .. CHATTER_CMD .. " " .. emu.romname())

local file_test = io.open(state_filename, "r")
if file_test == nil then
	print("No ROM state class found, exiting...")
	return
end
file_test:close()

local serial_test = io.open(SERIAL_DEVICE, "r")
if serial_test == nil then
	print("No serial device found, exiting...")
	return
end
serial_test:close()

print("Found a ROM state class for: " .. state_filename)

local rom = loadfile(state_filename)()

-- Turn off DTR control, we don't want the Arduino resetting everytime we make a connection
os.execute("stty -F /dev/ttyACM0 " .. BAUD_RATE .. " time 0 -hupcl -brkint -icrnl -imaxbel -opost -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke")
wserial = io.open(SERIAL_DEVICE, "w+b")

if wserial then
	print("Opened serial port, registering tick")
	print("MODE: Initial mode")
	write_serial(MODE_GAME_OVER)
	emu.register_frame(tick)
end
