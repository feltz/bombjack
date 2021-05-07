AStar = Object:extend()
Node = Object:extend()

function Node:new (point, cost, parent)
  self.parent, self.point, self.cost = parent, point, cost or 0
end

function Node:calcCost (source, destination)
  self.cost = calc_distance (destination.point[1], destination.point[2], self.point[1], self.point[2])
  self.cost = self.cost + calc_distance (source.point[1], source.point[2], self.point[1], self.point[2])
end

function Node:isInList (list)
  local in_list = nil
  for _, node in ipairs (list) do
    if self.point[1] == node.point[1] and self.point[2] == node.point[2] then
      return self
    end
  end
  return in_list
end

-- Le constructeur attend une grille à deux dimensions de taille quelconque avec des 0 et 1. Les obstacles sont indiqués avec des 1.
-- La fonction membre getPath attend 2 listes avec à chaque fois les coordonnées de départ et de destination

function AStar:new (grid)
  self.grid = grid
  self.nx, self.ny = #self.grid, #self.grid[1]
  self.to_explore, self.visited = {}, {}
  self.source, self.destination = {}, {}
end

function AStar:addNeighbours (node)
  for i = -1,1 do
    for j = -1,1 do
      if math.abs (i) ~= math.abs (j) then
        local neighbour_point = {node.point[1] + i, node.point[2] + j}
        if neighbour_point[1] > 0 and neighbour_point[2] > 0 and neighbour_point[1] <= self.nx and neighbour_point[2] <= self.ny
           and self.grid[neighbour_point[1]][neighbour_point[2]] == 0 then
          -- On vérifie si visité ou non
          local visited = false
          for _, a_visited_node in pairs (self.visited) do
            if a_visited_node.point[1] == neighbour_point[1] and a_visited_node.point[2] == neighbour_point[2] then
              visited = true
              break
            end
          end
          if not visited then          
            local new_node = Node (neighbour_point, 0, node)
            new_node:calcCost(self.source, self.destination)
            -- On vérifie si le nouveau noeud était déjà dans la liste des noeuds à explorer
            local already_present = false
            for idx, a_node_to_be_explored in pairs (self.to_explore) do
              if a_node_to_be_explored.point[1] == new_node.point[1] and a_node_to_be_explored.point[2] == new_node.point[2] then
                already_present = true
                if a_node_to_be_explored.cost > new_node.cost then
                  a_node_to_be_explored.cost = new_node.cost
                  a_node_to_be_explored.parent = new_node.parent
                  break
                end
              end
            end
            if not already_present then
              table.insert (self.to_explore, new_node)
            end
          end
        end
      end
    end
  end
end

function AStar:addParentToPath (path, node)
  if node.parent then
    table.insert (path, 1, node.point)
    self:addParentToPath (path, node.parent)
  end
end

function AStar:draw() 
  if DEBUG_BIRD then
    for i = 1,15 do
      for j = 1,15 do
        love.graphics.print (tostring (self.grid[i][j]), i*16-8, j*16-8)
        love.graphics.rectangle ("line", i*16-8, j*16-8, 16, 16)
      end
    end
  end
end

function AStar:getPath (source, destination)
  if source[1] == destination[1] and source[2] == destination[2] then
    return {source}
  end
  self.source, self.destination = Node (source), Node (destination)
  self.to_explore, self.visited = { self.source }, {}
  local is_dest_in_to_be_explored_list, node_found = nil, nil
  while #self.to_explore > 0 and not is_dest_in_to_be_explored_list do
    local minimum = {cost = self.nx * self.ny, idx = -1}
    for i, n in pairs (self.to_explore) do
      if n.cost < minimum.cost then
        minimum = {cost = n.cost, idx = i}
      end
    end
    node_found = table.remove (self.to_explore, minimum.idx)
    table.insert (self.visited, node_found)
    self:addNeighbours (node_found)
    is_dest_in_to_be_explored_list = self.destination:isInList (self.to_explore)
  end
  self.destination.parent = node_found
  local path = {self.destination.point}
  self:addParentToPath(path, self.destination)
  return path
end