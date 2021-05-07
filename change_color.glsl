extern vec4 fromColors[7];
extern vec4 toColors[7];
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
  for (int i = 0; i < 7 ; i++)
    if (pixel == fromColors[i])
      pixel = toColors[i];
  return pixel;
}