seat_positions = {}
local POKER_WIDTH = 137
local POKER_HEIGHT = 176
seat_positions[2] = {
	[1] = {
		pos = cc.p(display.cx/2, 157),
		poker_pos = cc.p(100, -140),
		fight_pos = cc.p(500, 0)
	},
	[2] = {
		pos = cc.p(display.cx/2, display.top - 157),
		poker_pos = cc.p(100, -40),
		fight_pos = cc.p(500, 0)
	}
} 

seat_positions[3] = {
	[1] = {
		pos = cc.p(300, 156),
		poker_pos = cc.p(80, -146),
		fight_pos = cc.p(180, 120),
	},
	
	[2] = {
		pos = cc.p(display.width - 100, display.top - 100),
		poker_pos = cc.p(-240 - 137 - 80, -126),
		fight_pos = cc.p(-150, -126 - 86),
		is_right = 150 + POKER_WIDTH
	},
	[3] = {
		pos = cc.p(100, display.top - 100),
		poker_pos = cc.p(80, -126),
		fight_pos = cc.p(150, -126 - 86),
	},
} 

seat_positions[4] = {
	[1] = {
		pos = cc.p(300, 156),
		poker_pos = cc.p(80, -146),
		fight_pos = cc.p(180, 120),
	},
	
	[2] = {
		pos = cc.p(display.width - 100, display.top - 100),
		poker_pos = cc.p(-240 - 137 - 80, -126),
		fight_pos = cc.p(-150, -126 - 86),
		is_right = 150 + POKER_WIDTH
	},
	[3] = {
		pos = cc.p(100, display.top - 100),
		poker_pos = cc.p(80, -126),
		fight_pos = cc.p(150, -126 - 86),
	},

	[3] = {
		pos = cc.p(100, display.top - 100),
		poker_pos = cc.p(80, -126),
		fight_pos = cc.p(150, -126 - 86),
	},
} 