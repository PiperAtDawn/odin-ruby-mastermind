# Adding methods to String to color the text and its background
class String
  def black;          "\e[30m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def no_colors
    gsub /\e\[\d+m/, ''
  end

  def bg(color)
    case color
    when 'red'
      black.bg_red
    when 'green'
      black.bg_green
    when 'blue'
      black.bg_blue
    when 'magenta'
      black.bg_magenta
    when 'brown'
      black.bg_brown
    when 'gray'
      black.bg_gray
    else
      gsub /\e\[\d+m/, ''
    end
  end
end
