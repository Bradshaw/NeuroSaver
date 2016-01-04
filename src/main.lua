

function love.load(arg)
	
	font = love.graphics.newFont("fonts/04B_03__.TTF",32)
	love.graphics.setFont(font)
	diplodocus = require "diplodocus"
	useful = diplodocus.useful
	require("UI")
	gstate = require "gamestate"
	game = require "game"
	gstate.registerEvents()
	gstate.switch(game)
end