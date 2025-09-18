def word_stats(text)
  words = text.scan(/\w+/)                
  total = words.size                      
  longest = words.max_by(&:length)        
  unique = words.map(&:downcase).uniq.size 

  "#{total} слів, найдовше: #{longest}, унікальних: #{unique}"
end

print "Введіть рядок: "
input = gets.chomp
puts word_stats(input)
