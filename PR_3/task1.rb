#!/usr/bin/env ruby
# -----------------------------------------
# Лабораторна робота
# Тема: Сканер дублікатів у файловій системі
# Мова: Ruby
# Автор: (впиши своє ім'я)
# -----------------------------------------

require 'digest'   # Для створення хешів файлів (SHA256)
require 'json'     # Для створення звіту у форматі JSON
require 'find'     # Для рекурсивного обходу директорій

# -----------------------------------------
# Функція: рекурсивно збирає всі файли в каталозі
# root   - коренева директорія
# ignore - список ігнорованих шляхів (наприклад, системні)
# Повертає масив хешів: { path, size, inode(optional) }
# -----------------------------------------
def collect_files(root, ignore = [])
  files = []

  Find.find(root) do |path|
    next if File.directory?(path)                   # Пропускаємо папки
    next if ignore.any? { |skip| path.include?(skip) }  # Ігноруємо вказані шляхи

    begin
      stat = File.stat(path)
      files << { path: path, size: stat.size, inode: stat.ino }
    rescue => e
      warn "Помилка доступу до файлу #{path}: #{e.message}"
    end
  end

  files
end

# -----------------------------------------
# Функція: групує файли за розміром (попередні дублікати)
# Повертає хеш { size => [файли] }
# -----------------------------------------
def group_by_size(files)
  files.group_by { |f| f[:size] }.select { |_, v| v.size > 1 }
end

# -----------------------------------------
# Функція: обчислює SHA256-хеш для файлу
# -----------------------------------------
def file_hash(path)
  Digest::SHA256.file(path).hexdigest
rescue => e
  warn "Помилка читання #{path}: #{e.message}"
  nil
end

# -----------------------------------------
# Функція: підтверджує дублікати через хеш
# -----------------------------------------
def confirm_duplicates(groups_by_size)
  confirmed = []

  groups_by_size.each_value do |group|
    hash_groups = group.group_by { |f| file_hash(f[:path]) }.select { |_, v| v.size > 1 }

    hash_groups.each do |hash, files|
      size = files.first[:size]
      saved = (files.size - 1) * size
      confirmed << {
        size_bytes: size,
        saved_if_dedup_bytes: saved,
        files: files.map { |f| f[:path] }
      }
    end
  end

  confirmed
end

# -----------------------------------------
# Основна програма
# -----------------------------------------

root_dir = ARGV[0] || '.'  # Якщо не вказано шлях – поточна папка
ignore_list = ['.git', 'node_modules', 'tmp']

puts "🔍 Сканую каталог: #{root_dir} ..."
all_files = collect_files(root_dir, ignore_list)
puts "📂 Знайдено файлів: #{all_files.size}"

puts "🧩 Групую за розміром..."
size_groups = group_by_size(all_files)

puts "🧠 Перевіряю вміст файлів..."
duplicates = confirm_duplicates(size_groups)

# -----------------------------------------
# Зберігаємо звіт у JSON
# -----------------------------------------
report = {
  scanned_files: all_files.size,
  groups: duplicates
}

File.open('duplicates.json', 'w') do |f|
  f.write(JSON.pretty_generate(report))
end

puts "✅ Звіт збережено у файлі duplicates.json"
puts "🔸 Груп дублікатів знайдено: #{duplicates.size}"
