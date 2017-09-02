game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x8529) > 0x00)
	end,

	coins = function(self)
		return self:memory():read_u8(0x85A5)
	end,

	players = function(self)
		return self:memory():read_u8(0x840A)
	end,

	score = function(self)
		return 0
	end,

	hiscore = function(self)
		return 0
	end
}
