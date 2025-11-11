# frozen_string_literal: true

require_relative 'csv_detective/version'
require_relative 'csv_detective/detector'

module CSVDetective
  # Public API: CSVDetective::Detector.detect(path_or_string)
  # Returns hash: { delimiter: ",", quote_char: '"', encoding: "UTF-8" }
end
