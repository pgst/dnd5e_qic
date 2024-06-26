class UserAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :examination
  delegate :question_txt, to: :examination, prefix: false

  # 指定したidのレコードを取得
  scope :get_by_id, ->(id) { find(id) }
  # ユーザーのquestion_numの最大値を取得
  scope :get_question_num_all, ->(id, num) { where(user_id: id).maximum(num) }
  # ユーザーのquestion_numが1以上のレコードの中で最小のidを取得
  scope :get_id_first, ->(id) { where(user_id: id, question_num: 1..).minimum(:id) }

  # 提出前の回答欄レコードを確認して、回答欄レコードが存在しない場合は作成
  def self.review_and_create(user_id, question_num_all)
    # 受験回数、ただし初回受験時ならばnilなので0を返す
    attempts_num = where(user_id: user_id).maximum(:attempts_num) || 0

    # 初回受験時は回答欄レコードを作成
    return create_user_answers(user_id, question_num_all, attempts_num) if attempts_num == 0

    # 二度目の受験以降は未回答の回答欄レコードが存在するか確認
    user_answers = where(user_id: user_id, question_num: 1..).order(:question_num)
    # 未回答の回答欄レコードが存在する場合はそのまま遷移
    if user_answers.present?
      return true, user_answers.first.id, nil
    else
      # 回答欄レコードを作成
      return create_user_answers(user_id, question_num_all, attempts_num)
    end
  end

  # 合否判定して、正解数と合否結果と保存の成否を返す
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
      return 0, false, false if !ua.save
    end

    if user_answers.size > 0 && Float(user_answers.size * ENV['PASSING_SCORE_THRESHOLD'].to_f / 100) <= Float(correct_num)
      passed = true
      User.find(id).increment!(:passed_num)
    else
      passed = false
    end

    return correct_num, passed, true
  end

  # 現在のユーザーと回答者が異なるかを判定
  def belongs_to_user?(user_id)
    self.user_id == user_id
  end

  # 選択されている回答をフラグに変換
  def get_choiced_ans_flags
    @choiced_ans_yes = self.choiced_ans == 'yes'
    @choiced_ans_no = self.choiced_ans == 'no'
    return @choiced_ans_yes, @choiced_ans_no
  end

  # 最大すなわち、最終問題かを判定
  def is_last_question?(user_id)
    self.question_num == UserAnswer.get_question_num_all(user_id, :question_num)
  end

  # 回答した選択肢の更新
  def update_choiced_ans(params)
    self.choiced_ans = params[:choiced_ans]
    begin
      self.save!
      return true, nil
    rescue ActiveRecord::RecordInvalid => e
      return false, e.record.errors.full_messages
    end
  end

  private

  def self.create_user_answers(user_id, question_num_all, attempts_num)
    # 使用可能な問題のIDをランダムにquestion_num_all個取得
    examination_ids_rand = Examination.get_examination_ids_rand(question_num_all)

    # 回答欄レコードを作成
    user_answers = []
    examination_ids_rand.size.times do |i|
      user_answer = UserAnswer.new
      user_answer.user_id = user_id
      user_answer.examination_id = examination_ids_rand[i]
      user_answer.attempts_num = attempts_num + 1
      user_answer.question_num = i + 1
      user_answers << user_answer
    end

    # 回答欄レコードを保存
    begin
      return true, user_answers.first.id, nil if user_answers.all?(&:save!)
    rescue ActiveRecord::RecordInvalid => e
      return false, nil, e.record.errors.full_messages
    end
  end
end
