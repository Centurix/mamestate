game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x0029) ~= 0xFF)
	end,

	coins = function(self)
		return self:memory():read_u8(0x001D)
	end,

	players = function(self)
		return self:memory():read_u8(0x0029)
	end,

	score = function(self)
		return self:bcd2dec(0x002D)
	end,

	hiscore = function(self)
		return self:bcd2dec(0x0033)
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
