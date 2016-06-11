class Annotation < ActiveRecord::Base
	belongs_to :budgetpost, :foreign_key => 'budgetpost_id'
	validates :budgetpost_id, presence: true
end
