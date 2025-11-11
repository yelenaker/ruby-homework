# frozen_string_literal: true

# ------------------------------
# Лабораторна робота 6
# Тема: Часткове застосування (currying) для 3-аргументної лямбди
# ------------------------------

# Лямбда, яку будемо каррувати
sum3 = ->(a, b, c) { a + b + c }

# curry3: функція, яка перетворює proc/lambda у каровану версію
def curry3(proc_or_lambda)
  # Перевірка, що передали callable
  unless proc_or_lambda.respond_to?(:call)
    raise ArgumentError, "Expected a Proc or Lambda"
  end

  # Створюємо новий callable, який збирає аргументи по частинах
  lambda do |*args_so_far|
    # Внутрішня рекурсивна функція
    build = lambda do |*more_args|
      all_args = args_so_far + more_args

      if all_args.size < 3
        # якщо аргументів менше 3, повертаємо новий callable, що чекає решту
        curry3(lambda { |*next_args| proc_or_lambda.call(*(all_args + next_args)) })
      elsif all_args.size == 3
        # якщо аргументів рівно 3 — викликаємо оригінальний proc
        proc_or_lambda.call(*all_args)
      else
        # якщо більше 3 — помилка
        raise ArgumentError, "Too many arguments (got #{all_args.size}, expected 3)"
      end
    end

    build.call
  end
end

# ------------------------------
# Демонстрація роботи
# ------------------------------
puts "--- Демонстрація sum3 ---"
cur = curry3(sum3)

puts cur.call(1).call(2).call(3)     #=> 6
puts cur.call(1, 2).call(3)          #=> 6
puts cur.call(1).call(2, 3)          #=> 6
puts cur.call()                       #=> callable
puts cur.call(1, 2, 3)                #=> 6

begin
  cur.call(1, 2, 3, 4)                #=> ArgumentError
rescue ArgumentError => e
  puts "Error: #{e.message}"
end

# Інший приклад
puts "--- Демонстрація f ---"
f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)

puts cF.call('A').call('B', 'C')     #=> "A-B-C"
