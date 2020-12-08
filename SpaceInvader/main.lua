function love.load()
	love.window.setTitle('Philly Invaders')

	music = love.audio.newSource('tufight.mp3', 'stream')
	music:setLooping(true)
	love.audio.play(music)
	game_over = false
	game_win = false
	player = {}
	player.x = 0
	player.y = 500
	player.bullets = {}
	player.fire_cooldown = 20
	player.speed = 5
	player.image = love.graphics.newImage('player.png')
	player.fire_sound = love.audio.newSource('jawn.mp3', 'stream')
	player.explode_sound = love.audio.newSource('lose.mp3', 'stream')
	player.victory = love.audio.newSource('victory.mp3', 'stream')
	
	player.fire = function()
		if player.fire_cooldown <= 0 then
			love.audio.play(player.fire_sound)
			player.fire_cooldown = 20
			bullet = {}
			bullet.x = player.x + 29.5
			bullet.y = player.y
			table.insert(player.bullets, bullet)
		end
	end

	for i=0, 7 do
		enemies_controller:spawnEnemy(enemies_controller.drex, i * 80, 0)
		enemies_controller:spawnEnemy(enemies_controller.sju, i * 80, 60)
		enemies_controller:spawnEnemy(enemies_controller.vill, i * 80, 120)
		enemies_controller:spawnEnemy(enemies_controller.penst, i * 80, 180)
		enemies_controller:spawnEnemy(enemies_controller.penn, i * 80, 240)
	end
end


love.graphics.setDefaultFilter('nearest', 'nearest')
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.drex = love.graphics.newImage('drexel.png')
enemies_controller.sju = love.graphics.newImage('fsju.png')
enemies_controller.vill = love.graphics.newImage('nova.png')
enemies_controller.penst = love.graphics.newImage('pedst.png')
enemies_controller.penn = love.graphics.newImage('upenn.png')
particle_systems = {}
particle_systems.list = {}
particle_systems.img = love.graphics.newImage('particle.png')
enemies_controller.explode_sound = love.audio.newSource('enemy_hit.mp3', 'stream')
score = 0

function particle_systems:spawn(x, y)
	local ps = {}
	ps.x = x
	ps.y = y
	ps.ps = love.graphics.newParticleSystem(particle_systems.img, 32)
	ps.ps:setParticleLifetime(2,4)
	ps.ps:setEmissionRate(5)
	ps.ps:setSizeVariation(1)
	ps.ps:setLinearAcceleration(-20, -20, 20, 20)
	ps.ps:setColors(100, 255, 100, 255, 0, 255, 0, 255)
	table.insert(particle_systems.list, ps)
end


function particle_systems:draw()
	for _, v in pairs(particle_systems.list) do
		love.graphics.draw(v.ps, v.x, v.y)
	end
end


function particle_systems:update(dt)
	for _, v in pairs(particle_systems.list) do
		v.ps:update(dt)
	end
end


function particle_systems:cleanup()

end

function checkCollisions(enemies, bullets)
	for i, e in ipairs(enemies) do
		for _, b in pairs(bullets)do
			if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
				particle_systems:spawn(e.x, e.y)
				love.audio.play(enemies_controller.explode_sound)
				table.remove(enemies, i)
				score = score + 10
				table.remove(player.bullets)
			end
		end
	end
end


function enemies_controller:spawnEnemy(color, x, y)
	enemy = {}
	enemy.x = x + 80
	enemy.y = y
	enemy.width = 60
	enemy.height = 60
	enemy.bullets = {}
	enemy.fire_cooldown = 20
	enemy.speed = .20
	enemy.hz_speed = 1.3
	table.insert(self.enemies, enemy)
	enemy.color = color
end


function enemy:fire()
	if self.fire_cooldown <= 0 then
		self.fire_cooldown = 20
		bullet = {}
		bullet.x = self.x + 41
		bullet.y = self.y
		table.insert(self.bullets, bullet)
	end
end
function love.update(dt)
	player.fire_cooldown = player.fire_cooldown - 1
	if love.keyboard.isDown('right') then
		if player.x >= 780 then
			player.x = 0
		else
			player.x = player.x + player.speed
		end
	elseif love.keyboard.isDown('left') then
		if player.x <= -60 then
			player.x = 799
		else
			player.x = player.x - player.speed
		end
	end

	if love.keyboard.isDown('space') then
		player.fire()
	end

	if love.keyboard.isDown('q') then
		love.event.quit()
	end

	if #enemies_controller.enemies == 0 then
		game_win = true
	end

	for _, e in pairs(enemies_controller.enemies) do
		if e.y >= love.graphics.getHeight() / 1.1 then
			game_over = true
		end

		e.y = e.y + 1 * enemy.speed
	end

	for i, b in ipairs(player.bullets) do
		if b.y < -10 then
			table.remove(player.bullets)
			-- table.remove(player.bullets, i)
		end
		b.y = b.y - 10
	end

	checkCollisions(enemies_controller.enemies, player.bullets)
end


function love.draw()
	love.graphics.setNewFont(10)
	love.graphics.setColor(50, 50, 255)
	love.graphics.print('Score: ' .. score, 720, 5)

	love.graphics.setNewFont(90)
	if game_over then
		love.audio.stop(music)
		love.audio.play(player.explode_sound)
		love.graphics.setColor(255, 50, 50)
		love.graphics.print('You Loser!', 180, 20)
		return
	elseif game_win then
		love.audio.stop(music)
		love.audio.play(player.victory)
		love.graphics.setColor(99, 255, 32)
		love.graphics.print('Winner!', 190, 20)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(player.image, player.x, player.y, 0, .5)

	for _, e in pairs(enemies_controller.enemies) do
		love.graphics.draw(e.color, e.x, e.y, 0, .5)
	end

	love.graphics.setColor(255, 255, 255)
	for _,b in pairs(player.bullets) do
		love.graphics.rectangle('fill', b.x, b.y, 12, 10)
	end
end

