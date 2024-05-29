require 'csv'

csv = CSV.read('db/examinations.csv', headers: false)

csv.each do |row|
  Examination.create!(
    question_txt: row[0],
    correct_ans: row[1],
    can_use: true
  )
end
