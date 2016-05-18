class Budgetpost < ActiveRecord::Base
   belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
   has_many :comments, dependent: :destroy
   default_scope -> { order(created_at: :desc) }
   mount_uploader :picture, PictureUploader
   validates :user_id, presence: true
   validates :content, presence: true
   validate  :picture_size

   #belongs_to :user, :foreign_key => 'userid'
#   has_many :annotations_budgetposts
 #  has_many :annotations, :through => :annotations_budgetposts
  # belongs_to :shared_budget
   #belongs_to :shared_budget_member, :foreign_key => 'shared_budget_member_id', :class_name => 'Budget'

   has_many :budget, :foreign_key => 'budget_id'
   has_many :expenses, :class_name => 'Budget', :foreign_key => 'budget_id'
   has_many :revenues, :class_name => 'Budget', :foreign_key => 'budget_id'

  #before_save :generate_display_year

 # TODO: add caching and passing of default vals if this is making too many round-trips to the database 
 # returns a <item.category> => value hash for either all expenses or all revenues of a budget  
  def get_budget_items(isexpense=true) 
    return Hash[self.budget.select{ |item| item.isexpense == isexpense} \
                    .map{|item| [item.subcategory.downcase, item.value]}] 
  end 

  # Due to current many->1 relationship in the DB, we must do a deep copy of budget items 
  # return a new budget with the cloned budget_items and the specified user_id 
  # does not clone annotations
  def clone_with_associations(user_id)
    new_budget = self.clone 
    new_budget.userid = user_id
    cloned_budget_items = [] 
    self.budget.each do |budget_item| 
      cloned_item = budget_item.clone
      cloned_item.save
      cloned_budget_items += [cloned_item] 
    end 
    new_budget.budget = cloned_budget_items 
    new_budget.save 
    return new_budget 
  end 

  def has_expenses_and_revenues?
    # Disabling this check because the performance overhead is significant,
    # requiring two additional database queries per budget
    # errors[:base] << "doesn't have either expenses or revenues, or both." if not (expenses.length > 0 and revenues.length > 0)
  end

  def balance
    value = 0
    self.budget.each do |bi|
      if bi.isexpense then value -= bi.dollarAmount
      else value += bi.dollarAmount end
    end
    value
  end

  def self.latest(conditions={})
    conds = ''
    conditions.each do |key, value|
      conds += " and budgets.#{key} = '#{value}'"
    end
    self.find(:all,
      :joins => :budget,
      :include => [:user, :budget],
      :order => "budget.updated_at DESC",
      :group => 'budgets.id',
      :limit => 10,
      :conditions => "budgets.user_id != 0#{conds}")
  end

  def self.popular(conditions={})
    conds = ''
    conditions.each do |key, value|
      conds += " and budgets.#{key} = '#{value}'"
    end
    self.find(:all,
      :joins => :likes,
      :include => [:user, :budget],
      :order => 'COUNT(*) DESC',
      :group => 'budgets.id',
      :limit => 10,
      :conditions => "budgets.user_id != 0#{conds}")
  end

  def self.all_except(id)
    self.where("id != #{id}")
  end

  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
=begin
    def generate_display_year
      year = self.year.to_s
      self.display_year = if year.size == 8 then "#{year[0..3]}-#{year[4..7]}"
                          else year end
    end
=end
end