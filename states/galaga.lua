game = {
	memory = function(self)
		return manager:machine().devices[":maincpu"].spaces["program"]
	end,

	playing = function(self)
		return (self:memory():read_u8(0x9B70) == 0x01)
	end,

	coins = function(self)
		return self:memory():read_u8(0x8035) -- Not quite right
	end,

	players = function(self)
		return 0
	end,

	score = function(self)
		return 0
	end,

	hiscore = function(self)
		return 0
	end
}
