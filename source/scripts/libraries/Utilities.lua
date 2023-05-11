function math.clamp(value, min, max)
	if (min > max) then
		min, max = max, min
	end
	return math.max(min, math.min(max, value))
end

function math.ring(value, min, max)
	if (min > max) then
		min, max = max, min
	end
	return min + (value - min) % (max - min)
end

function math.ringInt(value, min, max)
	return math.ring(value, min, max + 1)
end

function math.sign(value)
	return (value >= 0 and 1) or -1
end

-- https://www.lua.org/pil/11.4.html
Queue = {}
function Queue.new(size)
	local queue = table.create(size + 2, 0)
	queue.first = 0
	queue.last = -1
	return queue
end

function Queue.push(queue, value)
	local last = queue.last + 1
	queue.last = last
	queue[last] = value
end

function Queue.pop(queue)
	local first = queue.first
	if first > queue.last then
		return nil
	end
	local value = queue[first]
	queue[first] = nil -- to allow garbage collection
	queue.first = first + 1
	return value
end
