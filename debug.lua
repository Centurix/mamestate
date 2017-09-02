-- mame -autoboot_script ~/mame/scripts/debug.lua -console puckman

function memdump(mem_object)
	-- Dump memory
	memory = {}
	for i=0, 0xFFFF do
		memory[i] = mem_object:read_i8(i)
	end
	return memory
end

function memdiff(dump1, dump2, old_value, new_value)
	-- Find a difference between dumps where the old dump has old_value and the new dump has new_value
	for i=0, 0xFFFF do
		if dump1[i] == old_value and dump2[i] == new_value then
			print(string.format("Found a match: %x", i))
		end
	end
end

function show_devices()
	for k,v in pairs(manager:machine().devices) do 
		print(k) 
	end
end

function show_spaces()
	cpu = manager:machine().devices[":maincpu"]
	for k,v in pairs(cpu.spaces) do 
		print(k) 
	end
end

function get_space(space_name)
	cpu = manager:machine().devices[":maincpu"];
	return cpu.spaces[space_name];
end

function pause()
	emu.pause()
end

function unpause()
	emu.unpause()
end

function showmem(mem_object, from, to)
	for i = from, to do
		print(string.format("0x%x ", mem_object:read_i8(i)))
	end
end


