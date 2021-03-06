game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x0060) > 0x00)
	end,

	coins = function(self)
		return self:memory():read_u8(0x0023)
	end,

	players = function(self)
		return self:memory():read_u8(0x0060)
	end,

	score = function(self)
		return self:bcd2dec(0x0068) -- BCD: 1234 = 12 34
	end,

	hiscore = function(self)
		return self:bcd2dec(0x00D0) -- BCD: 1234 = 12 34
	end,

	bcd2dec = function(self, address)
		bytes = {}
		for byte_address = address, address + 3 do
			byte = self:memory():read_u8(byte_address)
			bytes[#bytes + 1] = (byte & 0xF0) >> 4
			bytes[#bytes + 1] = byte & 0x0F
		end

		total = 0

		for index, value in ipairs(bytes) do
			total = total + (value * math.floor(10 ^ (8 - index)))
		end

		return total
	end
}
