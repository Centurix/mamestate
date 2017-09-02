-- All counts are in BCD
-- 8070 == 01: Play flag 
-- 8017: Credits
-- 819B: Player count
-- 819C-819F: Current player score
-- 81B5-81B9: Player 1 score storage
-- 81CE-81D1: Player 2 score storage
-- 80E2-80E3: Hi score scratch pad, including current in have hi score
-- 8100-815F: Hi score table

game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x8070) == 0x01)
	end,

	coins = function(self)
		return self:memory():read_u8(0x8017)
	end,

	players = function(self)
		return self:memory():read_u8(0x819B)
	end,

	score = function(self)
		return self:bcd2dec(0x819C)
	end,

	hiscore = function(self)
		return self:bcd2dec(0x80E2)
	end,

	bcd2dec = function(self, address)
		bytes = {}
		for byte_address = address, address + 3 do
			byte = self:memory():read_u8(byte_address)
			bytes[#bytes + 1] = byte & 0x0F
			bytes[#bytes + 1] = (byte & 0xF0) >> 4
		end

		total = 0
		for index, value in ipairs(bytes) do
			total = total + (value * math.floor(10 ^ (index - 1)))
		end

		return total
	end
}
