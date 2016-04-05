require 'active_support/all'
require 'csv'

QUESTIONS = [
  'Favourite camp moments? Did a camp member make your burn super amazing?',
  'What do you feel was your contribution to the camp? Could something have helped you to contribute more?<br><br>',
  'Favourite meal?',
  'Why did you choose to camp with Helioz this year?',
  'Will you come back next year?',
  'One thing you wish you had known before, or wish you had brought to the burn?',
  'Did you experience or observe any bad behaviour in the camp? (Unauthorised borrowing, mooping, etc. - please give details.) Are there any camp rules that we should add or change for next year?',
  'Did you like the location at 9:15 + B? Where should we ask to be placed next year?',
  'What could make Helioz awesome in 2016? What would you like to contribute? Any other thoughts?'
]

rows = CSV.read(File.expand_path('../data/example.csv', __FILE__), headers: true)

def wrap(string, width = 100)
  string.gsub /(.{1,#{width}})(\s+|\Z)/, "\\1\n"
end

QUESTIONS.each_with_index do |question, index|
  title = "(#{index}) #{question}"

  puts
  puts '=' * title.size
  puts title
  puts '=' * title.size

  rows.select do |row|
    row[question].present?
  end.each_with_index do |row, index|
    answer = row[question]

    next if answer == 'Open-Ended Response'

    answer = answer.gsub('  ', "\n")

    puts
    puts "-- #{index} --"
    puts wrap(answer)
    puts
  end

  puts
end
