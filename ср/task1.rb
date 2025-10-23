# ================================
# Клас FileBatchEnumerator
# ================================
# Цей клас зчитує великий файл не весь одразу, а по N рядків за раз.
# Це зручно, коли файл дуже великий і не влазить у пам'ять.
# Ми робимо власний ітератор, який можна використовувати у циклах.
# ================================

class FileBatchEnumerator
  include Enumerable   # додаємо, щоб можна було користуватись each, map, тощо

  def initialize(file_path, batch_size = 5)
    @file_path = file_path       # шлях до файлу
    @batch_size = batch_size     # скільки рядків читати за раз
  end

  # Метод each — основа будь-якого ітератора в Ruby
  def each
    return enum_for(:each) unless block_given?

    # Відкриваємо файл
    File.open(@file_path, "r") do |file|
      batch = []  # масив для тимчасового зберігання рядків

      file.each_line do |line|
        batch << line.chomp  # додаємо рядок у батч, прибираємо \n
        if batch.size == @batch_size
          yield batch        # передаємо батч далі у блок
          batch = []         # очищуємо перед наступним набором
        end
      end

      # Якщо лишились рядки, менше ніж batch_size — теж віддаємо
      yield batch unless batch.empty?
    end
  end
end

# ================================
# Приклад використання
# ================================

# Створимо тестовий файл
File.write("big_file.txt", (1..13).map { |i| "Рядок #{i}" }.join("\n"))

# Створюємо екземпляр ітератора
enumerator = FileBatchEnumerator.new("big_file.txt", 4)

# Використання в циклі each
enumerator.each do |batch|
  puts "Батч:"
  puts batch
  puts "---"
end
