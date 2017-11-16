class Sprite3D
  attr_accessor :x, :y, :z
  def initialize(p_window, filename)
    @p_window = p_window
    @sprites = Gosu::Image.load_tiles(@p_window, filename, 32, 32, true)
    
    @sprites.each do |sprite|
      glBindTexture(GL_TEXTURE_2D, sprite.gl_tex_info.tex_name)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    end
    
    @directions = {
      :down_left => 0,
      :down_right => 1,
      :up_left => 2,
      :up_right => 3,
      :down => 4,
      :up => 5,
      :left => 6,
      :right => 7
    }
    
    @current_direction = :down
    @current_frame = 0.0
    @number_of_frames = 6
    @x, @y, @z = 0.0, 0.0, 0.0
    @size = 1.0
    @destinations = Array.new
  end
  
  def find_path_to(destination)
    results = @p_window.map.find_path([@x.floor, @z.floor], [destination[0], destination[1]])
    if results != nil 
      @destinations = results.reverse
    end
    @step_destination = 0
  end
  
  def add_path_to(destination)
    if !@destinations.empty?
      results = @p_window.map.find_path([@destinations.last[0], @destinations.last[1]], [destination[0], destination[1]])
      if results != nil 
        @destinations += results.reverse
      end
    else
      find_path_to(destination)
    end
  end
  
  def draw
    frame = @directions[@current_direction] * @number_of_frames + @current_frame.round
    texture = @sprites[frame].gl_tex_info
    glBindTexture(GL_TEXTURE_2D, texture.tex_name)
    
    glEnable(GL_ALPHA_TEST)
    glAlphaFunc(GL_GREATER, 0)
      
    glBegin(GL_QUADS)
    # WARNING ! Can cause problems with collisions !
      glTexCoord2f(texture.left, texture.bottom); glVertex3f(@x, @y, @z + 0.5)
      glTexCoord2f(texture.right, texture.bottom); glVertex3f(@x + @size, @y, @z + 0.5)
      glTexCoord2f(texture.right, texture.top); glVertex3f(@x + @size, @y + @size, @z + 0.5)
      glTexCoord2f(texture.left, texture.top); glVertex3f(@x, @y + @size, @z + 0.5)
    glEnd
    
    glDisable(GL_ALPHA_TEST)
  end
  
  def move(direction)
    move_speed = 0.0625
    diag_speed = 1.0
    frame_speed = 0.1
    
    @current_direction = direction
    case @current_direction
      when :down
        @z += move_speed
      when :up
        @z -= move_speed
      when :left
        @x -= move_speed
      when :right
        @x += move_speed
      when :up_left
        @x -= diag_speed
        @z -= diag_speed
      when :up_right
        @x += diag_speed
        @z -= diag_speed
      when :down_left
        @x -= diag_speed
        @z += diag_speed
      when :down_right
        @x += diag_speed
        @z += diag_speed
    end
      
    # ANIMATION
    @current_frame += frame_speed
    @current_frame = 0.0 if @current_frame >= @number_of_frames - 1    
  end
  
  def update
    if @destinations != nil and !@destinations.empty?
      if @step_destination >= @destinations.size
        @destinations = Array.new
      else
        destination_x = @destinations[@step_destination][0]
        destination_z = @destinations[@step_destination][1]
        if @x < destination_x and @z > destination_z
          move(:up_right)
        elsif @x > destination_x and @z > destination_z  
          move(:up_left)
        elsif @x > destination_x and @z < destination_z  
          move(:down_left)
        elsif @x < destination_x and @z < destination_z  
          move(:down_right)
        elsif @x < destination_x  
          move(:right)
        elsif @x > destination_x  
          move(:left)
        elsif @z > destination_z  
          move(:up)
        elsif @z < destination_z  
          move(:down)
        end
        
        if @x == destination_x and @z == destination_z
          @step_destination += 1
        end
      end
    else
      @current_frame = 0.0
    end
  end
end
