class Examination < ApplicationRecord
  has_many :user_answers

  # 使用可能な全問題数を取得
  def self.get_examination_count
    where(can_use: true).pluck(:id).size
  end

  # 使用可能な全問題データを取得
  def self.get_examination_all
    where(can_use: true).all
  end

  def self.get_examination_ids_rand(question_num_all)
    where(can_use: true).order("RANDOM()").limit(question_num_all).pluck(:id)
  end
end
