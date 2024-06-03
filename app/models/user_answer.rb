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

  # ユーザーのquestion_numの最大値を取得
  def self.get_question_num_all(id, num)
    where(user_id: id).maximum(num)
  end

  # ユーザーのquestion_numが1以上のレコードの中で最小のidを取得
  def self.get_id_first(id)
    where(user_id: id, question_num: 1..).minimum(:id)
  end

  # 合否判定を行って結果を返す
  def self.results(id)
    user_answers = includes(:examination).where(user_id: id, question_num: 1..).order(:question_num)

    correct_num = 0
    user_answers.each do |ua|
      if ua.choiced_ans == ua.examination.correct_ans
        ua.cleared = true
        correct_num += 1
      else
        ua.cleared = false
      end

      ua.question_num = 0
      return 0, false, false unless ua.save
    end

    if user_answers.size > 0 && (user_answers.size * ENV['PASSING_SCORE_THRESHOLD'].to_i / 100).ceil <= correct_num  # 正答率が65%以上の場合
      passed = true
      User.find(id).increment!(:passed_num)
    else
      passed = false
    end

    return correct_num, passed, true
  end
end
