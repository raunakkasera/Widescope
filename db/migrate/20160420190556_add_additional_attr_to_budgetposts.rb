class AddAdditionalAttrToBudgetposts < ActiveRecord::Migration
  	def self.up
      add_column :budgetposts, :budgetId, :integer
      add_column :budgetposts, :statecode, :string
      add_column :budgetposts, :year, :integer
      add_column :budgetposts, :subcategory, :string
      add_column :budgetposts, :isexpense, :boolean
      add_column :budgetposts, :dollarAmount, :float
      add_column :budgetposts, :supercategory, :string
      add_column :budgetposts, :annotationId, :integer
      add_column :budgetposts, :isbaseline, :boolean
      add_column :budgetposts, :author, :string
      add_column :budgetposts, :comments, :string
      add_column :budgetposts, :reference, :string
    end

  def self.down
      remove_column :budgetposts, :budgetId, :integer
      remove_column :budgetposts, :statecode, :string
      remove_column :budgetposts, :year, :integer
      remove_column :budgetposts, :subcategory, :string
      remove_column :budgetposts, :isexpense, :boolean
      remove_column :budgetposts, :dollarAmount, :float
      remove_column :budgetposts, :supercategory, :string
      remove_column :budgetposts, :annotationId, :integer
      remove_column :budgetposts, :isbaseline, :boolean
      remove_column :budgetposts, :author, :string
      remove_column :budgetposts, :comments, :string
      remove_column :budgetposts, :reference, :string
  end
  
end
