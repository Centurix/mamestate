-- All counts are in BCD
-- 2011 > 00: Play flag 
-- 20EB: Credits
-- 21FF: Player count (22FF P2)
-- 20F8-20F9: Current player score
-- 20F8-20F9: Player 1 score storage
-- 20FC-20FD: Player 2 score storage
-- 20F4-20F5: Hi score scratch pad, including current in have hi score
-- 20F4-20F5: Hi score table

game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x2011) == 0x00)
	end,

	coins = function(self)
		return self:bcd2dec(0x20EB, 1)
	end,

	players = function(self)
		return self:memory():read_u8(0x21FF)
	end,

	score = function(self)
		return self:bcd2dec(0x20F8, 2)
	end,

	hiscore = function(self)
		return self:bcd2dec(0x20F4, 2)
	end,

	bcd2dec = function(self, address, length)
		bytes = {}
		for byte_address = address + (length - 1), address, -1 do
			byte = self:memory():read_u8(byte_address)
			bytes[#bytes + 1] = (byte & 0xF0) >> 4
			bytes[#bytes + 1] = byte & 0x0F
		end

		total = 0

		for index, value in ipairs(bytes) do
			total = total + (value * math.floor(10 ^ ((2 * length) - index)))
		end

		return total
	end
}
