math.randomseed(os.time())
for i=1,100000 do
	math.random()
end

function love.load(arg)
	
	font = love.graphics.newFont("fonts/visitor1.ttf",20)
	love.graphics.setFont(font)
	diplodocus = require "diplodocus"
	useful = diplodocus.useful
	require("neuro")
	require("UI")
	gstate = require "gamestate"
	game = require "game"
	gstate.registerEvents()
	gstate.switch(game)
end