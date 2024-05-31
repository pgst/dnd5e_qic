require 'csv'

# 試験問題データを取り込む
examinations_csv = CSV.read('db/examinations.csv', headers: true)
examinations_csv.each do |row|
  can_use = row[3] == 'true' ? true : false
  created_at = row[4] == '' ? Time.current : row[4]
  updated_at = row[5] == '' ? Time.current : row[5]

  Examination.create!(
    id: row[0],
    question_txt: row[1],
    correct_ans: row[2],
    can_use: can_use,
    created_at: created_at,
    updated_at: updated_at
  )
end

# ユーザーデータを取り込む
users_csv = CSV.read('db/users.csv', headers: true)
users_csv.each do |row|
  admin = row[5] == 'true' ? true : false
  created_at = row[6] == '' ? Time.current : row[6]
  updated_at = row[7] == '' ? Time.current : row[7]

  User.create!(
    id: row[0],
    name: row[1],
    image: row[2],
    uid: row[3],
    passed_num: row[4],
    admin: admin,
    created_at: created_at,
    updated_at: updated_at
  )
end

# 回答欄データを取り込む
user_answers_csv = CSV.read('db/user_answers.csv', headers: true)
user_answers_csv.each do |row|
  choiced_ans = row[1] == ' - ' ? nil : row[1]
  cleared = row[2] == 'true' ? true : false
  created_at = row[6] == '' ? Time.current : row[5]
  updated_at = row[7] == '' ? Time.current : row[6]

  UserAnswer.create!(
    id: row[0],
    choiced_ans: choiced_ans,
    cleared: cleared,
    attempts_num: row[3],
    question_num: row[4],
    created_at: created_at,
    updated_at: updated_at,
    user_id: row[7],
    examination_id: row[8]
  )
end
