require 'active_support/all'
require 'csv'

class Question < Struct.new(:long, :short)
  def self.find(long)
    QUESTIONS.detect do |question|
      question.long == long
    end
  end

  def self.max_size
    QUESTIONS.collect do |question|
      question.to_s.size
    end.max
  end

  def to_s
    short
  end

  def self.score(answers)
    numerator = answers.sum do |answer, counter|
      index = ANSWERS.index(answer) - 2

      index * counter
    end

    denominator = answers.values.sum

    numerator.to_f / denominator.to_f
  end
end

class Answer < Struct.new(:long, :short)
  def self.find(long)
    ANSWERS.detect do |answer|
      answer.long == long
    end
  end

  def self.max_size
    ANSWERS.collect do |answer|
      answer.to_s.size
    end.max
  end

  def to_s
    short
  end
end

QUESTIONS = {
                                                         'Dinners' => 'Dinners',
                                                        'Brunches' => 'Brunches',
                                              'Kitchen facilities' => 'Kitchen',
                                            'Inverted disco dome!' => 'Disco Dome',
                                             'Glowing bocce ball!' => 'Bocce Ball',
                                                          'Arena!' => 'Arena',
                                          'TARB the drinks robot!' => 'TARB',
                                                    'Sound system' => 'Sound',
                                    'Tools for setup and teardown' => 'Setup/Teardown Tools',
                                                'Shade structures' => 'Shade',
                                                          'Shower' => 'Shower',
                                                       'Furniture' => 'Furniture',
                                                         'Signage' => 'Signage',
                                                 'Camp decoration' => 'Decoration',
                       'Pre-burn expectations setting and support' => 'Pre-Burn Support',
                              'Communal camp fun group activities' => 'Group Activities',
                   'Introduction to the camp setup and facilities' => 'Campsite Introduction',
                        'Support for virgins (first time burners)' => 'Virgin Support',
                              'Campmate recruitment and screening' => 'Recruiting/Screening',
  'Holding people to account for antisocial behaviour in the camp' => 'Accountability',
       'Interactive activities for other burners (not at Helioz!)' => 'Interactivity',
            'Diversity of campmates (different backgrounds, etc.)' => 'Diversity'
}.collect do |long, short|
  Question.new long, short
end

ANSWERS = {
                    'Way too much camp effort went into this' => 'Way Too Much',
                                  'We spent too much on this' => 'Too Much',
                                           'Perfect balance!' => 'Perfect',
                                    'Deserves more attention' => 'Too Little',
  'Awesome! More effort and resources really should go here!' => 'Way Too Little'
}.collect do |long, short|
  Answer.new long, short
end

COUNTERS = QUESTIONS.each_with_object({}) do |question, counters|
  counters[question] = ANSWERS.each_with_object({}) do |answer, counters|
    counters[answer] = 0
  end
end

csv = CSV.read(File.expand_path('../data/example.csv', __FILE__))

csv_table = []

csv.each_with_index do |row, index|
  next if index == 0

  csv_table << row.from(21).to(-2).to_csv
end

csv_table = csv_table.join("\n")

CSV.parse csv_table, headers: true do |row|
  row.each do |key, value|
    question = Question.find(key.gsub(/ - .*/, ''))
    answer = Answer.find(value)

    COUNTERS[question][answer] += 1 if answer.present?
  end
end

COUNTERS.sort_by do |question, answers|
  Question.score answers
end.reverse.each do |question, answers|
  scale = 5

  puts
  puts question
  puts '-' * question.size

  answers.each do |answer, counter|
    puts "#{answer.to_s.rjust Answer.max_size}: #{sprintf '%5.2f', counter} |#{'=' * counter * scale}"
  end

  puts "#{'Total'.rjust Answer.max_size}: #{sprintf '%5.2f', answers.values.sum}"
  puts "#{'Average'.rjust Answer.max_size}: #{sprintf '%5.2f', Question.score(answers)}"

  # Output for Keynote:
  # answers.to_a.reverse.each do |answer, counter|
  #   puts [answer, counter].join("\t")
  # end

  puts
end

puts
puts 'Averages'
puts '--------'

COUNTERS.sort_by do |question, answers|
  Question.score answers
end.reverse.each do |question, answers|
  scale = 50

  score = Question.score(answers)

  left = score.negative? ? '=' * (score.abs * scale) : ''
  right = score.positive? ? '=' * (score.abs * scale) : ''

  puts "#{question.to_s.rjust Question.max_size}: #{sprintf '%5.2f', score} #{left.rjust 40}|#{right.ljust 40}"

  # Output for Keynote:
  # puts [question, score].join("\t")
end

puts
