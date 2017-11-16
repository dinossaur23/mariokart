require 'rubygems'
require 'bundler'
require 'opengl'
Bundler.require(:default)

require 'gl'
require 'glu'
require 'glut'
require 'gosu'
include Gl
include Glu
include Glut


class Mario
  def initialize
    @sprites = Gosu::Image.load_tiles("project/mario.png", 32, 32, tileable: true)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
  end
  def warp(x, y)
    @x, @y = x, y
  end
  def turn_left(mapa)
    # @angle -= 1.5 unless mapa.blocked?(@y, @x - 1.5)
    @angle -= 1.5 unless mapa.blocked?(@y, @x)
  end
  def turn_right(mapa)
    # @angle += 1.5 unless mapa.blocked?(@y, @x + 1.5)
    @angle += 1.5 unless mapa.blocked?(@y, @x)
  end
  def accelerate(mapa)
    #@vel_x += Gosu::offset_x(@angle, 0.2) unless mapa.blocked?(@y - 50, @x)
    # @vel_y += Gosu::offset_y(@angle, 0.2) unless mapa.blocked?(@y - 50, @x)
    # if mapa.blocked?(@y - 50, @x - 50)
    #   @vel_x = Gosu::offset_x(@angle, 0)
    # else
    #   @vel_x += Gosu::offset_x(@angle, 0.2)
    # end
    #
    if mapa.blocked?(@y, @x)
      @vel_y = 0
      @vel_x = 0
      @vel_x -= Gosu::offset_x(@angle, 4)
      @vel_y -= Gosu::offset_y(@angle, 4)
    else
      # puts mapa.finish_line?(@y, @x)
      @vel_x += Gosu::offset_x(@angle, 0.2)
      @vel_y += Gosu::offset_y(@angle, 0.2)
    end
  end
  def re(mapa)
    if mapa.blocked?(@y, @x)
      @vel_y = 0
      @vel_x = 0
      @vel_x += Gosu::offset_x(@angle, 0.2)
      @vel_y += Gosu::offset_y(@angle, 0.2)
    else
      @vel_x -= Gosu::offset_x(@angle, 0.2)
      @vel_y -= Gosu::offset_y(@angle, 0.2)
    end
  end
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 600
    @y %= 600
    @vel_x *= 0.9
    @vel_y *= 0.9
  end

  def draw
    # @second.draw(52,10,1
    texture = @sprites[5]#.gl_tex_info
    # glBindTexture(GL_TEXTURE_2D, texture)
    texture.draw_rot(@x, @y, 1, @angle)
  end
end

class Luigi
  def initialize
    @sprites = Gosu::Image.load_tiles("project/luigi.png", 32, 32, tileable: true)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
  end
  def warp(x, y)
    @x, @y = x, y
  end
  def turn_left
    @angle -= 4.5
  end
  def turn_right
    @angle += 4.5
  end
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.2)
    @vel_y += Gosu::offset_y(@angle, 0.2)
  end
  def re
    @vel_x -= Gosu::offset_x(@angle, 0.2)
    @vel_y -= Gosu::offset_y(@angle, 0.2)
  end
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 360
    @y %= 360
    @vel_x *= 0.9
    @vel_y *= 0.9
  end

  def draw
    # @second.draw(52,10,1)
    texture = @sprites[5]#.gl_tex_info
    # glBindTexture(GL_TEXTURE_2D, texture)
    texture.draw_rot(@x, @y, 1, @angle)
  end
end

class Tile
  attr_reader :position

  def initialize(tileset, tile_pos, collidable: false, finish: false)
    @image = tileset[tile_pos]
    @position = tile_pos
    @collidable = collidable
    @finish = finish
  end

  def collidable?
    @collidable
  end

  def finish?
    @finish
  end
end

class Map

  TILE_SIZE = 8

  # La position des tuiles que l'on va utiliser dans la tileset 994
  GRASS_POS = 0
  TRACK_POS = 1
  FINISH_POS = 258
  B_TRACK_POS = 995
  Y_TRACK_POS = 994
  G_TRACK_POS = 993
  R_TRACK_POS = 992

  HEIGHT = 600
  WIDTH = 600
  NUMBER_OF_LINE = HEIGHT / TILE_SIZE  # 75

  ZORDER = 1

  def initialize(tiles_path)
    @tileset = Gosu::Image.load_tiles(tiles_path, TILE_SIZE, TILE_SIZE, tileable: true)
    @board = generate_board
  end

  def draw
      # @viewport
      # glGetIntegerv( GL_VIEWPORT)
      #
      # glMatrixMode( GL_PROJECTION )
      # glLoadIdentity()
      # gluOrtho2D( 0, @viewport[2], @viewport[3], 0 )
      # glMatrixMode( GL_MODELVIEW )
      # glLoadIdentity()
      # glDisable( GL_DEPTH_TEST )
      # glDisable( GL_LIGHTING )
      # glDisable( GL_TEXTURE_2D )
      #

    # On parcourt le tableau case par case pour afficher les tuiles
    @board.each_with_index do |line, height|
      line.each_with_index do |tile, width|

        # On pense à multiplier par `TILE_SIZE` pour ne pas afficher
        # toutes les cases les unes sur les autres.
        # puts "#{height}, #{width}" if tile.position == FINISH_POS
        # 48, 31
        # 68, 31
        @tileset[tile.position].draw(height * TILE_SIZE, width * TILE_SIZE, ZORDER)
      end
    end
    # // Making sure we can render 3d again
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    # //glPopMatrix();        ----and this?
    # draw_rot(1, 1, 1, 0.5, center_x=0.5, center_y=0.5, scale_x=1, scale_y=1, color=0xff_ffffff, mode=:default);
  end

  def blocked?(tile_y, tile_x)
    null = nil
    tile = @board[tile_x/ TILE_SIZE][tile_y / TILE_SIZE]
    return false unless tile
    tile.collidable?
  end

  def finish_line?(tile_y, tile_x)
    null = nil
    tile = @board[(tile_x/ TILE_SIZE).to_i][(tile_y / TILE_SIZE).to_i]
    return false unless tile
    tile.finish?
  end

  private

  # On génère la carte avec des murs sur les côtés
  def generate_board
    board = Array.new(NUMBER_OF_LINE, [])

    # esquerdo
    5.times do |i|
      board[i] = Array.new(NUMBER_OF_LINE, Tile.new(@tileset, GRASS_POS, collidable: true, finish: false))
    end

    line = []
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    (NUMBER_OF_LINE - 10).times do
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    end
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    board[5] = line

    15.times do |i|
      line = []

      5.times do
        line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
      end
      # (NUMBER_OF_LINE - 10).times do
        line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
        # board[i]=
        (NUMBER_OF_LINE - 12).times do
          line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
        end
        line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
      # end
      5.times do
        line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
      end
      board[i + 6] = line
    end

    line = []
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    15.times do
      line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
    end
    33.times do
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    end
    15.times do
      line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
    end
    line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    board[21] = line

    25.times do |i|
      line = []
      5.times do
        line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
      end
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
      15.times do
        line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
      end
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
      31.times do
        line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
      end
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
      15.times do
        line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
      end
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
      5.times do
        line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
      end
      board[i + 22] = line
    end

    line = []
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    15.times do
      line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
    end
    33.times do
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    end
    15.times do
      line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
    end
    line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    board[47] = line

    21.times do |i|
      line = []
      5.times do
        line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
      end
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
      25.times do
        line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
      end
      line << Tile.new(@tileset, FINISH_POS, collidable: false, finish: true)
      37.times do
        line << Tile.new(@tileset, TRACK_POS, collidable: false, finish: false)
      end
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
      5.times do
        line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
      end
      board[i + 48] = line
    end

    line = []
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    (NUMBER_OF_LINE - 10).times do
      line << Tile.new(@tileset, Y_TRACK_POS, collidable: true, finish: false)
    end
    5.times do
      line << Tile.new(@tileset, GRASS_POS, collidable: true, finish: false)
    end
    board[69] = line

    # direito
    5.times do |i|
      board[NUMBER_OF_LINE - 1 - i] = Array.new(NUMBER_OF_LINE, Tile.new(@tileset, GRASS_POS, collidable: true, finish: false))
    end
    board
  end
end

class Cube
  def initialize
    @mario = Gosu::Image.new("project/cube_mario2.png", tileable: true).gl_tex_info
    @luigi = Gosu::Image.new("project/cube_luigi.png", tileable: true).gl_tex_info
    @yoshi = Gosu::Image.new("project/cube_yoshi.png", tileable: true).gl_tex_info
    @peach = Gosu::Image.new("project/cube_peach.png", tileable: true).gl_tex_info
    # @toad = Gosu::Image.new("project/cube_toad.png", tileable: true).gl_tex_info
    # @koopa = Gosu::Image.new("project/cube_koopa.png", tileable: true).gl_tex_info
    @x = @y = @vel_x = @vel_y = @angle = @cube_angle = 0.0
  end


  def draw
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # see lesson01
      glMatrixMode(GL_PROJECTION) # see lesson01
      glLoadIdentity  # see lesson01
      gluPerspective(45.0, 1.0, 0.1, 100.0) # see lesson01
      glMatrixMode(GL_MODELVIEW) # see lesson01
      glLoadIdentity # see lesson01

      glTranslatef(0, 0, -5) # see lesson01

      glEnable(GL_TEXTURE_2D) # enables two-dimensional texturing to perform

      glBindTexture(GL_TEXTURE_2D, @mario.tex_name)
      glBindTexture(GL_TEXTURE_2D, @luigi.tex_name)
      glBindTexture(GL_TEXTURE_2D, @peach.tex_name)
      glBindTexture(GL_TEXTURE_2D, @yoshi.tex_name)
      # glBindTexture(GL_TEXTURE_2D, @toad.tex_name)
      # glBindTexture(GL_TEXTURE_2D, @koopa.tex_name)

      glRotatef(@cube_angle, 1.0, 1.0, 1.0)

      glBegin(GL_QUADS)
          # Draw the right side
          glTexCoord2f(1, 1)
          glVertex3f( 1.0,  1.0, -1.0)
          glTexCoord2f(0, 1)
          glVertex3f( 1.0,  1.0,  1.0)
          glTexCoord2f(0, 0)
          glVertex3f( 1.0, -1.0,  1.0)
          glTexCoord2f(1, 0)
          glVertex3f( 1.0, -1.0, -1.0)
          # Draw the top side
          glTexCoord2f(1, 1)
          glVertex3f( 1.0,  1.0, -1.0)
          glTexCoord2f(0, 1)
          glVertex3f(-1.0,  1.0, -1.0)
          glTexCoord2f(0, 0)
          glVertex3f(-1.0,  1.0,  1.0)
          glTexCoord2f(1, 0)
          glVertex3f( 1.0,  1.0,  1.0)
          # Draw the bottom side
          glTexCoord2f(1, 1)
          glVertex3f( 1.0, -1.0,  1.0)
          glTexCoord2f(0, 1)
          glVertex3f(-1.0, -1.0,  1.0)
          glTexCoord2f(0, 0)
          glVertex3f(-1.0, -1.0, -1.0)
          glTexCoord2f(1, 0)
          glVertex3f( 1.0, -1.0, -1.0)
          # Draw the front side
          glTexCoord2f(1, 1)
          glVertex3f( 1.0,  1.0,  1.0)
          glTexCoord2f(0, 1)
          glVertex3f(-1.0,  1.0,  1.0)
          glTexCoord2f(0, 0)
          glVertex3f(-1.0, -1.0,  1.0)
          glTexCoord2f(1, 0)
          glVertex3f( 1.0, -1.0,  1.0)
          # Draw the back side
          glTexCoord2f(1, 1)
          glVertex3f( 1.0, -1.0, -1.0)
          glTexCoord2f(0, 1)
          glVertex3f(-1.0, -1.0, -1.0)
          glTexCoord2f(0, 0)
          glVertex3f(-1.0,  1.0, -1.0)
          glTexCoord2f(1, 0)
          glVertex3f( 1.0,  1.0, -1.0)
          # Draw the left side
          glTexCoord2f(1, 1)
          glVertex3f(-1.0,  1.0,  1.0)
          glTexCoord2f(0, 1)
          glVertex3f(-1.0,  1.0, -1.0)
          glTexCoord2f(0, 0)
          glVertex3f(-1.0, -1.0, -1.0)
          glTexCoord2f(1, 0)
          glVertex3f(-1.0, -1.0,  1.0)
      glEnd


      @cube_angle -= 0.15

      glutSwapBuffers
  end
end

class GameWindow < Gosu::Window
  def initialize
    @initial = 0
    super 600, 600
    self.caption = "Mario Kart Game"
    # @background_image = Gosu::Image.new("project/mariocircuit.png", tileable: true)
    @cube = Cube.new
    @map = Map.new("project/tiles.png")
    @mario = Mario.new
    @luigi = Luigi.new
    @mario.warp(1670, 850)
    @luigi.warp(1720, 880)
    @camera_x = @camera_y = 0
  end
  def update
    if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      @mario.turn_left(@map)
    end
    if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      @mario.turn_right(@map)
    end
    if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      @mario.accelerate(@map)
    end
    if button_down? Gosu::KbDown or button_down? Gosu::GpDown then
      @mario.re(@map)
    end

    if button_down? Gosu::KbQ then
      @luigi.turn_left
    end
    if button_down? Gosu::KbE then
      @luigi.turn_right
    end
    if button_down? Gosu::KbW then
      @luigi.accelerate
    end
    if button_down? Gosu::KbS then
      @luigi.re
    end

    if button_down? Gosu::KB_F1 then
      @initial = 1
    end

    @luigi.move
    @mario.move
  end
  def draw
    # Gosu.rotate(1, around_x = 500, around_y = 400) do
    # Gosu.translate(10,10) do
      if @initial == 0
        @map.draw
        @mario.draw
        @luigi.draw
      else
        @cube.draw
      end


    # end
    # @background_image.draw(0, 0, 0);
  end
  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show
# font = Gosu::Font.new(window, Gosu::default_font_name, 50)
# font.draw("teste", 100, 100, 1.0, 1.0, 1.0, 0xffffffff)
