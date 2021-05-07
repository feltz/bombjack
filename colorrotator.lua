ColorRotator = Object:extend()

function ColorRotator:initColorRotator (color_table, time_limit) 
  self.step_color_time, self.rotating_colors = 0, nil  
  self.time_limit = time_limit or 0.05
  if color_table then
    self:startColorRotation (color_table)
  end
end

function ColorRotator:getColorTable () 
  return self.rotating_colors
end

function ColorRotator:startColorRotation (color_table) 
  self.rotating_colors = ColorRotator.cloneColorTable (color_table)
end

function ColorRotator.cloneColorTable (color_table) 
  local new_table = {}
  for i, rgb in ipairs (color_table) do
    new_table[i] = {rgb[1], rgb[2], rgb[3], rgb[4]}
  end
  return new_table
end

function ColorRotator:stopColorRotation () 
  self.rotating_colors = nil
end

function ColorRotator:rotateColorTable (dt) 
  if self.rotating_colors then
    self.step_color_time = self.step_color_time + dt
    if self.step_color_time > self.time_limit then
      self.step_color_time = 0
      ColorRotator.rotateTable (self.rotating_colors)
    end
  end
end

function ColorRotator.rotateTable (table)
  local save = table[#table]
  for i=#table,2,-1 do
    table[i] = table[i-1]
  end
  table[1] = save
  return table
end
