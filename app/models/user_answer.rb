class UserAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :examination

  # 受験回数を取得
  def self.get_attempts_num(user_id)
    attempts_num = where(user_id:).maximum(:attempts_num)
    # 初回受験時はnilのため0を代入
    attempts_num ||= 0
  end

  # ユーザーのquestion_numが1以上のレコードを取得
  def self.get_user_answers(user_id)
    where(user_id:, question_num: 1..).order(:question_num)
  end

  # 指定したidのレコードを取得
  def self.get_user_answer(id)
    find(id)
  end

  # 回答欄データを作成して保存
  def self.set_user_answers(examination_ids_rand, user_id, attempts_num)
    user_answers = []
    examination_ids_rand.size.times do |i|
      user_answer = UserAnswer.new
      user_answer.user_id = user_id
      user_answer.examination_id = examination_ids_rand[i]
      user_answer.attempts_num = attempts_num + 1
      user_answer.question_num = i + 1
      user_answers << user_answer
    end
    user_answers
  end
end
