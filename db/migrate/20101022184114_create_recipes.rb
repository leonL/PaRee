class CreateRecipes < ActiveRecord::Migration
  def self.up
    create_table :recipes do |t|
      t.string :name
      t.text :notes
      t.string :yield
      t.text :ingredients
      t.text :directions
      t.integer :category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :recipes
  end
end
