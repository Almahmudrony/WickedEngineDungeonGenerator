-- Simplistic random dungeon generator lua script

dungeon={
	
	Generate = function(complexity)
	
		local scalingMat = matrix.Scale(Vector(10,10,10))
		local dungeonStartPos = Vector(0,0,0)
		
		-- This will hold the bounding boxes of the placed segments
		local boxes = {}
		
		-- threshold so that aabbs snapped to each other are not detected as intersecting
		-- because segments are needed to be snapped to each other
		-- chose this value so that it also eliminates floating point errors
		local aabb_threshold = Vector(0.05,0.05,0.05)
		
		-- Check if a segment can be placed or not by specifying its axis aligned bounding box
		local function CheckSegmentCanBePlaced(aabb)
			aabb = AABB(aabb.GetMin():Add(aabb_threshold), aabb.GetMax():Subtract(aabb_threshold))
			
			for i,box in ipairs(boxes) do
				if box.Intersects(aabb) then
					return false
				end
			end
			
			table.insert(boxes,aabb)
			
			return true
		end
		
		-- Place the start piece of the dungeon
		LoadModel("dungeon/start/","start","segment",scalingMat)
		LoadWorldInfo("dungeon/start/","start.wiw")
		CheckSegmentCanBePlaced(AABB(Vector(-1,0,-2),Vector(1,2,0)))
		
		-- Create physical dungeon segments recursively
		local function GenerateDungeon(i, count, pos, rotY)
			-- tag is a unique identifier for each segment
			local tag = "segment"..math.floor(pos.GetX())..math.floor(pos.GetY())..math.floor(pos.GetZ())
			local rotMat = matrix.RotationY(rotY)
			local transformMat = matrix.Multiply( rotMat, matrix.Multiply( matrix.Translation(pos), scalingMat ) )
			if (i >= count) then
				LoadModel("dungeon/end/","end",tag,transformMat)
				return;
			end
			
			
			local select = math.random(0, 100)
			if(select < 75) then -- common pieces
				local select2 = math.random(0, 4)
				if(select2 < 1) then --left turn
					if CheckSegmentCanBePlaced(AABB(Vector(-1,0,0),Vector(1,2,2)).Transform(transformMat)) then
						LoadModel("dungeon/turnleft/","turnleft",tag,transformMat)
						GenerateDungeon(i+1,count,pos:Add(Vector(-1,0,1).Transform(rotMat)),rotY-0.5*math.pi)
					else
						GenerateDungeon(i+1,count,pos,rotY)
					end
				elseif(select2 < 2) then --right turn
					if CheckSegmentCanBePlaced(AABB(Vector(-1,0,0),Vector(1,2,2)).Transform(transformMat)) then
						LoadModel("dungeon/turnright/","turnright",tag,transformMat)
						GenerateDungeon(i+1,count,pos:Add(Vector(1,0,1).Transform(rotMat)),rotY+0.5*math.pi)
					else
						GenerateDungeon(i+1,count,pos,rotY)
					end
				else --straight block
					if CheckSegmentCanBePlaced(AABB(Vector(-1,0,0),Vector(1,2,2)).Transform(transformMat)) then
						LoadModel("dungeon/block/","block",tag,transformMat)
						GenerateDungeon(i+1,count,pos:Add(Vector(0,0,2).Transform(rotMat)),rotY)
					else
						GenerateDungeon(i+1,count,pos,rotY)
					end
				end
			elseif(select < 98) then -- average pieces
				local select2 = math.random(0, 100)
				if( select2 < 20 ) then --small room left
					if CheckSegmentCanBePlaced(AABB(Vector(-5,0,0),Vector(1,2,6)).Transform(transformMat)) then
						LoadModel("dungeon/smallroomleft/","smallroomleft",tag,transformMat )
						GenerateDungeon(i+1,count,pos:Add(Vector(-5,0,5).Transform(rotMat)),rotY-0.5*math.pi)
					else
						GenerateDungeon(i+1,count,pos,rotY)
					end
				elseif( select2 < 30 ) then --odd corridor
					if CheckSegmentCanBePlaced(AABB(Vector(-1,0,0),Vector(3,2,8)).Transform(transformMat)) then
						LoadModel("dungeon/oddcorridor/","oddcorridor",tag,transformMat )
						GenerateDungeon(i+1,count,pos:Add(Vector(2,0,8).Transform(rotMat)),rotY)
					else
						GenerateDungeon(i+1,count,pos,rotY)
					end
				elseif( select2 < 60 ) then --up corridor
					if CheckSegmentCanBePlaced(AABB(Vector(-1,0,0),Vector(1,4,6)).Transform(transformMat)) then
						LoadModel("dungeon/upcorridor/","upcorridor",tag,transformMat )
						GenerateDungeon(i+1,count,pos:Add(Vector(0,2,6).Transform(rotMat)),rotY)
					else
						GenerateDungeon(i+1,count,pos,rotY)
					end
				else --corridor
					if CheckSegmentCanBePlaced(AABB(Vector(-1,0,0),Vector(1,2,6)).Transform(transformMat)) then
						LoadModel("dungeon/corridor/","corridor",tag,transformMat )
						GenerateDungeon(i+1,count,pos:Add(Vector(0,0,6).Transform(rotMat)),rotY)
					else
						GenerateDungeon(i+1,count,pos,rotY)
					end
				end
			else -- rare pieces
				if CheckSegmentCanBePlaced(AABB(Vector(-4,0,0),Vector(4,8,8)).Transform(transformMat)) then
					LoadModel("dungeon/room/","room",tag,transformMat )
					-- right
					GenerateDungeon(i+1,count,pos:Add(Vector(4,0,4).Transform(rotMat)),rotY + 0.5*math.pi)
					-- left
					GenerateDungeon(i+1,count,pos:Add(Vector(-4,0,4).Transform(rotMat)),rotY - 0.5*math.pi)
					-- straight
					GenerateDungeon(i+1,count,pos:Add(Vector(0,0,8).Transform(rotMat)),rotY)
				else
					GenerateDungeon(i+1,count,pos,rotY)
				end
			end
		end
		
		-- Call recursive generator function
		GenerateDungeon(0,complexity,dungeonStartPos,0)
		
	
	end,

}