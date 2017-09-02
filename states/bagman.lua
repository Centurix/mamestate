game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x6054) == 0x01)
	end,

	coins = function(self)
		return self:memory():read_u8(0x6000)
	end,

	players = function(self)
		return self:memory():read_u8(0x6056)
	end,

	score = function(self)
		-- 0x6176 = Player 1 score, 3 bytes per score, max score = 999,999
		-- 0x6179 = Player 2
		return self:bcd2dec(0x6176)
	end,

	hiscore = function(self)
		-- 0x6257
		return self:bcd2dec(0x6257)
	end,

	bcd2dec = function(self, address)
		bytes = {}
		for byte_address = address, address + 2 do
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
