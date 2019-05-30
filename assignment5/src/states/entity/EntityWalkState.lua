--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(entity)
	self.entity = entity
	self.entity:changeAnimation('walk-down')

	-- used for AI control
	self.moveDuration = 0
	self.movementTimer = 0

	-- keeps track of whether we just hit a wall
	self.bumped = false
end

function EntityWalkState:update(dt)

	if self.entity.health <= 0 then
		self.entity:changeState('idle')
		return
	end

	-- assume we didn't hit a wall
	self.bumped = false

	if self.entity.direction == 'left' then
		self.entity.x = self.entity.x - self.entity.walkSpeed * dt

		if self.entity.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
			self.entity.x = MAP_RENDER_OFFSET_X + TILE_SIZE
			self.bumped = true
		end
	elseif self.entity.direction == 'right' then
		self.entity.x = self.entity.x + self.entity.walkSpeed * dt

		if self.entity.x + self.entity.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
			self.entity.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.entity.width
			self.bumped = true
		end
	elseif self.entity.direction == 'up' then
		self.entity.y = self.entity.y - self.entity.walkSpeed * dt

		if self.entity.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2 then
			self.entity.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2
			self.bumped = true
		end
	elseif self.entity.direction == 'down' then
		self.entity.y = self.entity.y + self.entity.walkSpeed * dt

		local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE)
			+ MAP_RENDER_OFFSET_Y - TILE_SIZE

		if self.entity.y + self.entity.height >= bottomEdge then
			self.entity.y = bottomEdge - self.entity.height
			self.bumped = true
		end
	end

	if self.entity.flier == false then
		for k, object in pairs(self.entity.room.objects) do
			if object.solid then
				if self.entity:collides(object) then
					self.bumped = true
					self.entity:unCollide(object, dt)
				end
			end
		end
	end

	self.entity.hitbox:move(self.entity.x, self.entity.y)
	self.entity.hurtbox:move(self.entity.x, self.entity.y)
end

function EntityWalkState:processAI(dt)
	local directions
	-- if self.bumped then
	-- 	-- AS5.2 - forcing to walk a different direction than before
	-- 	-- Avoids buggy behavior
	-- 	-- if self.entity.direction == 'up' then
	-- 	-- 	directions = {'left', 'right', 'down'}
	-- 	-- elseif self.entity.direction == 'down' then
	-- 	-- 	directions = {'left', 'right', 'up'}
	-- 	-- elseif self.entity.direction == 'right' then
	-- 	-- 	directions = {'left', 'up', 'down'}
	-- 	-- else
	-- 	-- 	directions = {'right', 'up', 'down'}
	-- 	-- end
	-- 	-- self.moveDuration = math.random(5)
	-- 	-- self.entity.direction = directions[math.random(#directions)]
	-- 	-- self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
	-- 	-- self.entity:changeState('idle')
	-- 	self.bumped = false
	if self.moveDuration == 0 or self.bumped then
		directions = {'left', 'right', 'up', 'down'}
		-- set an initial move duration and direction
		self.moveDuration = math.random(5)
		self.entity.direction = directions[math.random(#directions)]
		self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
		if self.bumped then
			self.bumped = false
		end
	elseif self.movementTimer > self.moveDuration then
		self.movementTimer = 0
		directions = {'left', 'right', 'up', 'down'}
		-- chance to go idle
		if math.random(3) == 1 then
			self.entity:changeState('idle')
		else
			self.moveDuration = math.random(5)
			self.entity.direction = directions[math.random(#directions)]
			self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
		end
	end

	self.movementTimer = self.movementTimer + dt
end

function EntityWalkState:render()
	local anim = self.entity.currentAnimation
	love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
		math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

	-- love.graphics.setColor(255, 0, 255, 255)
	-- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
	-- love.graphics.setColor(255, 255, 255, 255)
end