class UserAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :examination

  # 受験回数を取得
  def self.get_attempts_num(user_id)
    attempts_num = where(user_id: user_id).maximum(:attempts_num)
    # 初回受験時はnilのため0を代入
    attempts_num ||= 0
  end
end
