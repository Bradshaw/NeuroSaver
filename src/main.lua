math.randomseed(os.time())
for i=1,100000 do
	math.random()
end

function love.load(arg)
	
	--font = love.graphics.newFont("fonts/visitor1.ttf",20)
	--font = love.graphics.newFont("fonts/04B_03__.TTF",16)
	font = love.graphics.newFont("fonts/timeburnernormal.ttf",30)
	love.graphics.setFont(font)
	diplodocus = require "diplodocus"
	useful = diplodocus.useful
	require("neuro")
	require("UI")
	require("spaceship")
	gstate = require "gamestate"
	game = require "game"
	gstate.registerEvents()
	gstate.switch(game)
end