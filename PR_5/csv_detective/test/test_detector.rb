# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../lib/csv_detective'

class TestDetector < Minitest::Test
  def test_comma_delimiter_and_double_quotes
    csv = <<~CSV
      "name","age","city"
      "Anna","30","Kyiv"
      "Ivan","25","Lviv"
    CSV

    result = CSVDetective::Detector.detect(csv)
    assert_equal ',', result[:delimiter]
    assert_equal '"', result[:quote_char]
    assert_equal 'UTF-8', result[:encoding]
  end

  def test_semicolon_and_single_quotes
    csv = " 'a';'b';'c'\n '1';'2';'3'\n"
    result = CSVDetective::Detector.detect(csv)
    # delimiter may be ';' and quote "'"
    assert_equal ';', result[:delimiter]
    assert_equal "'", result[:quote_char]
  end

  def test_tab_delimiter
    csv = "col1\tcol2\tcol3\n1\t2\t3\n4\t5\t6\n"
    result = CSVDetective::Detector.detect(csv)
    assert_equal "\t", result[:delimiter]
  end
end
