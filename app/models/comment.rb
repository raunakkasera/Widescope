class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :budgetpost
  default_scope -> { order(created_at: :desc) }
  validates :content, presence: true
  validates :user_id, presence: true
  validates :budgetpost_id, presence: true
end