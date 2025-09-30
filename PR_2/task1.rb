def cut_cake(cake)
  raisins = []
  cake.each_with_index do |row, i|
    row.chars.each_with_index do |c, j|
      raisins << [i, j] if c == "o"
    end
  end

  n = raisins.size
  h, w = cake.size, cake[0].size
  area = h * w
  piece_area = area / n

  parts = nil

  # горизонтальное деление
  if h % n == 0
    part_h = h / n
    parts = []
    n.times do |k|
      parts << cake[k*part_h...(k+1)*part_h]
    end

  # вертикальное деление
  elsif w % n == 0
    part_w = w / n
    parts = []
    n.times do |k|
      parts << cake.map { |row| row[k*part_w...(k+1)*part_w] }
    end
  else
    # fallback: кусок вокруг каждой изюминки
    parts = raisins.map do |(i, j)|
      piece = Array.new(h) { "." * w }
      piece[i][j] = "o"
      piece
    end
  end

  parts
end

examples = [
  [
    "........",
    "..o.....",
    "...o....",
    "........"
  ],
  [
    ".o......",
    "......o.",
    "....o...",
    "..o....."
  ],
  [
    "o...",
    ".o..",
    "..o.",
    "...o"
  ],
  [
    ".o.o....",
    "........",
    "....o...",
    "........",
    ".....o..",
    "........"
  ]
]

examples.each_with_index do |cake, idx|
  puts "\n=== Пример #{idx+1} ==="
  puts "Вход:"
  puts cake
  puts "Выход:"
  parts = cut_cake(cake)
  puts "["
  puts parts.map { |p| p.join("\n") }.join(",\n")
  puts "]"
end
