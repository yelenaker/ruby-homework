def play_game
  number = rand(1..100)        
  attempts = 0                 

  puts "Я загадав число від 1 до 100. Спробуй відгадати!"

  loop do
    print "Введи число: "
    guess = gets.to_i         
    attempts += 1

    if guess < number
      puts "Моє число більше!"
    elsif guess > number
      puts "Моє число менше!"
    else
      puts "Вітаю! Ти вгадала число #{number} за #{attempts} спроб(и)!"
      break                  
    end
  end
end

play_game
