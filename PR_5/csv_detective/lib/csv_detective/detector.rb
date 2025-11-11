# frozen_string_literal: true

require 'stringio'

module CSVDetective
  class Detector
    # Коротко: читаємо перші байти, пробуємо кілька кодувань,
    # для кожного кодування аналізуємо рядки і вибираємо
    # роздільник із найбільш стабільною кількістю колонок.
    #
    # Public:
    #   Detector.detect(path_or_string) => { delimiter:, quote_char:, encoding: }
    #
    CANDIDATE_DELIMITERS = [",", ";", "\t", "|", ":"].freeze
    CANDIDATE_ENCODINGS = ['UTF-8', 'Windows-1251', 'ISO-8859-1', 'CP1252', 'ASCII-8BIT'].freeze
    SNIFF_LINES = 20

    def self.detect(path_or_string)
      new(path_or_string).detect_all
    end

    def initialize(path_or_string)
      # Якщо передали шлях до файлу — читаємо байти, інакше трактуємо як байтовий рядок
      if path_or_string.is_a?(String) && File.file?(path_or_string)
        @raw = File.binread(path_or_string)
      else
        # Якщо користувач передав рядок в ЮТФ-8 — зберігаємо його в байтах
        @raw = path_or_string.to_s.b
      end
    end

    def detect_all
      enc = detect_encoding
      # якщо не знайшли нічого — падаємо назад до UTF-8 руками
      enc ||= 'UTF-8'
      text = safe_decode(@raw, enc)
      delim = detect_delimiter(text)
      quote = detect_quote(text)
      { delimiter: delim, quote_char: quote, encoding: enc }
    end

    private

    # Спробуємо знайти кодування, яке дозволяє без помилок
    # перетворити байти у UTF-8 і дати смислову таблицю колонок.
    def detect_encoding
      best = nil
      best_score = -Float::INFINITY

      CANDIDATE_ENCODINGS.each do |enc|
        begin
          s = @raw.dup.force_encoding(enc)
          # якщо рядок не валідний — пропускаємо
          next unless s.valid_encoding?

          # Перетворимо в UTF-8 щоб зручно аналізувати
          utf = s.encode('UTF-8')
          score = encoding_score(utf)
          if score > best_score
            best_score = score
            best = enc
          end
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
          next
        end
      end

      best
    end

    # Проста евристика: подивитися, чи рядки мають більше 1 колонки з якимось роздільником,
    # і наскільки стабільна кількість колонок — це підвищує score.
    def encoding_score(text)
      # беремо перші N рядків
      lines = text.lines.first(SNIFF_LINES)
      return -1000 if lines.empty?

      score = 0
      CANDIDATE_DELIMITERS.each do |d|
        counts = lines.map { |l| split_count(l, d) }
        median = median_of_array(counts)
        variance = variance_of_array(counts)
        # віддаємо перевагу високому числу колонок і низькій варіації
        score += (median * 10) - variance
      end
      score
    end

    # Кількість полів у рядковому рядку при простому розбитті (без CSV parsing)
    def split_count(line, delim)
      # Це дуже простий підхід — рахуємо скільки буде колонок
      line.split(delim, -1).length
    end

    def median_of_array(arr)
      a = arr.compact.sort
      return 0 if a.empty?
      mid = a.length / 2
      if a.length.odd?
        a[mid]
      else
        (a[mid - 1] + a[mid]) / 2.0
      end
    end

    def variance_of_array(arr)
      a = arr.compact
      return 0 if a.empty?
      m = a.sum.to_f / a.length
      a.map { |x| (x - m) ** 2 }.sum / a.length
    end

    # Повертає текст в UTF-8, надійно
    def safe_decode(raw_bytes, encoding)
      s = raw_bytes.dup.force_encoding(encoding)
      s = s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      s
    rescue
      raw_bytes.dup.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    end

    # Виявлення роздільника — обираємо той, що дає найбільш стабільну кількість колонок >1
    def detect_delimiter(text)
      lines = text.lines.first(SNIFF_LINES).map(&:chomp).reject(&:empty?)
      return ',' if lines.empty?

      best = { delim: ',', score: -Float::INFINITY }

      CANDIDATE_DELIMITERS.each do |d|
        counts = lines.map { |l| split_count(l, d) }
        median = median_of_array(counts)
        variance = variance_of_array(counts)
        # критерій: чим більше median (більше колонок), тим краще; менша variance — краще
        score = (median * 100) - variance
        if score > best[:score] && median >= 2
          best = { delim: d, score: score }
        end
      end

      best[:delim]
    end

    # Виявлення лапок: дивимось, чи більше подвійних " або одинарних '
    def detect_quote(text)
      # прості підрахунки, скільки разів зустрічаються "..." або '...'
      double_matches = text.scan(/"[^"\r\n]*"/).length
      single_matches = text.scan(/'[^'\r\n]*'/).length

      if double_matches >= single_matches && double_matches > 0
        '"'
      elsif single_matches > 0
        "'"
      else
        nil
      end
    end
  end
end
