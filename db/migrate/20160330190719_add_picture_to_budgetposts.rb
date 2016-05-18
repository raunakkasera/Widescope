class AddPictureToBudgetposts < ActiveRecord::Migration
  def change
    add_column :budgetposts, :picture, :string
  end
end
