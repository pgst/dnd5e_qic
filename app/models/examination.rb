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
end
