game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x4370) == 0xDD)
	end,

	coins = function(self)
		return self:memory():read_u8(0x4E6E)
	end,

	players = function(self)
		return self:memory():read_u8(0x4E70)
	end,

	score = function(self)
		-- Score is at 0x43F7, BCD full byte for a single digit. Lowest significant number first, number ends when 0x40 (@) is encountered
		return self:fullbytebcd2dec(0x43F7)
	end,

	hiscore = function(self)
		-- 0x43ED
		return self:fullbytebcd2dec(0x43ED)
	end,

	fullbytebcd2dec = function(self, address)
		total = 0
		index = 0

		repeat
			byte = self:memory():read_u8(address + index)
			if byte ~= 0x40 then
				total = total + (byte * math.floor(10 ^ index))
			end
			index = index + 1
		until(byte == 0x40)

		return total
	end
}
