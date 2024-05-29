class UserAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :examination
end
