class Examination < ApplicationRecord
  has_many :user_answers

  # 使用可能な全問題数を取得
  scope :get_examination_count, -> { where(can_use: true).pluck(:id).size }
  # 使用可能な全問題データのIDをランダムに取得
  scope :get_examination_ids_rand, -> (question_num_all) { where(can_use: true).order("RANDOM()").limit(question_num_all).pluck(:id) }
end
