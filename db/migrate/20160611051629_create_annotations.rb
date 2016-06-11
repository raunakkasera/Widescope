class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations do |t|
      t.integer :userId
      t.float :dollarAmount
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :annotations
  end
end