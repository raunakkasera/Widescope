class CreateBudgets < ActiveRecord::Migration
  def self.up
    create_table :budgets do |t|
      t.string :statecode
      t.integer :period
      t.string :author
      t.string :comments
      t.boolean :deficit_allowed
      t.boolean :surplus_allowed
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :budgets
  end
end
