require 'csv'

examinations_csv = CSV.read('db/examinations.csv', headers: false)
examinations_csv.each do |row|
  can_use = row[3] == 'true' ? true : false

  Examination.create!(
    id: row[0],
    question_txt: row[1],
    correct_ans: row[2],
    can_use: can_use
  )
end

users_csv = CSV.read('db/users.csv', headers: false)
users_csv.each do |row|
  admin = row[5] == 'true' ? true : false

  User.create!(
    id: row[0],
    name: row[1],
    image: row[2],
    uid: row[3],
    passed_num: row[4],
    admin: admin
  )
end

user_answers_csv = CSV.read('db/user_answers.csv', headers: false)
user_answers_csv.each do |row|
  choiced_ans = row[1] == ' - ' ? nil : row[1]
  cleared = row[2] == 'true' ? true : false

  UserAnswer.create!(
    id: row[0],
    choiced_ans: choiced_ans,
    cleared: cleared,
    attempts_num: row[3],
    question_num: row[4],
    created_at: row[5],
    updated_at: row[6],
    user_id: row[7],
    examination_id: row[8]
  )
end
