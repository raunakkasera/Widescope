class Budget < ActiveRecord::Base
  belongs_to :budgetpost, :foreign_key => 'budget_id'
  belongs_to :user, :foreign_key => 'user_id'
  #validate :is_value_positive?

  def value
    if self.isexpense 
      return -self.dollarAmount 
    else 
      return self.dollarAmount 
    end 
  end 

  # DEPRECATED
  def is_value_positive?
    errors[:base] << "it's meaningless for a budget item's amount to be negative" if dollarAmount < 0
  end
end