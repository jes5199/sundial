class Sundial
  attr_reader :latitude, :longitude
  def initialize(options)
    @latitude = options[:latitude]
    @longitude = options[:longitude]
  end

  def colatitude
    Degrees[90] - @latitude.abs
  end

  def noon_shadow_compass_direction
    return "perfectly vertical" if(@latitude == Degrees[0])
    (@latitude > Degrees[0]) ? "north" : "south"
  end

  def minutes_per_degree
    (24 * 60) / 360.0
  end
end

class EquatorialSundial < Sundial
  def description
    <<-DESC
  Your Equatorial Sundial at #{latitude}, #{longitude}
    The plane of your dial should be inclined to a #{colatitude} angle, #{lean}.
    The gnomen should be perpendicular to the dial, making a #{latitude.abs} angle with the ground.
    The gnomen on the summer/upper dial should point #{summer_gnomen_direction}.
    On the summer/upper/#{summer_gnomen_direction} dial, your numbers should run #{clockwise}.
    On the winter/lower/#{winter_gnomen_direction} dial, your numbers should run #{-clockwise}.
    Your timezone is probably centered at #{timezone_meridian}, so clock noon is #{solar_minutes}.
    You can set your sundial to show clock noon by rotating the dials #{solar_rotation} #{solar_rotation_direction} (as seen from the #{summer_gnomen_direction})
    You may want to rotate the summer dial an additional #{Degrees[15]} #{-clockwise} to observe daylight savings time.
    Your numerals should be spaced evenly, #{Degrees[15]} apart.
    Unless you are on the Equator, the sun will only light one side of your sundial at a time, except right around the equinox.
    You may omit digits on the summer side that are before sunrise or after sunset on the summer solstice.
    You may omit digits on the winter side that are before sunrise or after sunset on both equinoxes.
    DESC
  end

  def lean
    case @latitude
    when Degrees[0]; "perfectly vertical"
    when Degrees[90], Degrees[-90]; "perfectly horizontal"
    else "tilted toward the #{noon_shadow_compass_direction}"
    end
  end

  def summer_gnomen_direction
    (@latitude >= Degrees[0]) ? "north" : "south"
  end

  def winter_gnomen_direction
    return "perfectly vertical" if(@latitude == Degrees[90])
    (@latitude >= Degrees[0]) ? "south" : "north"
  end

  def clockwise
    (@latitude >= Degrees[0]) ? Clockwise : Anticlockwise
  end

  def timezone_meridian
    Degrees[(@longitude.angle / 15).round * 15]
  end

  def solar_minutes
    minutes = (longitude - timezone_meridian).angle * minutes_per_degree
    seconds = (minutes.abs * 60).to_i % 60
    "#{minutes.abs.to_i} minutes and #{seconds} seconds #{minutes > 0 ? 'after' : 'before'} solar noon"
  end

  def solar_rotation
    (longitude - timezone_meridian).abs
  end

  def solar_rotation_direction
    (longitude < timezone_meridian) ? -clockwise : clockwise
  end

  def describe(f = STDOUT)
    f.puts description
  end
end

module Clockwise
  def self.to_s
    "clockwise"
  end

  def self.-@
    Anticlockwise
  end

end

module Anticlockwise
  def self.to_s
    "anticlockwise"
  end

  def self.-@
    Clockwise
  end
end

class Degrees
  attr_reader :angle

  def initialize(d, m = 0, s = 0)
    sign = d < 0 ? -1 : 1
    @angle = sign * ( d.abs + (m.abs / 60) + (s.abs / (60*60)) )
  end

  def self.[](*args)
    new(*args)
  end

  def to_s
    "#{@angle}°"
  end

  def self.parse(str)
    str = str.dup
    negative = false
    if str.sub!(/^-/,"")
      negative = true
    end
    if str =~ /[WS]$/
      negative = !negative
    end
    d, m, s = str.split(/[^0-9.]+/).map(&:to_f)
    d *= (negative ? -1 : 1)
    self.new(d.to_f,m.to_f,s.to_f)
  end

  def abs
    self.class[ @angle.abs ]
  end

  def ==(other)
    self.angle == other.angle
  end

  def -(other)
    self.class[self.angle - other.angle]
  end

  def >(other)
    self.angle > other.angle
  end

  def >=(other)
    self.angle >= other.angle
  end

  def <(other)
    self.angle < other.angle
  end

  def <=(other)
    self.angle <= other.angle
  end
end

EquatorialSundial.new(:latitude => Degrees.parse(ARGV[0]), :longitude => Degrees.parse(ARGV[1])).describe

