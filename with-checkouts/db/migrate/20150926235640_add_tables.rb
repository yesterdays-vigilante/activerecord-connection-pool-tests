class AddTables < ActiveRecord::Migration
  def change
    create_table :cheeses do |t|
      t.string :name
      t.string :texture
      t.string :flavour
    end

    create_table :camelids do |t|
      t.string :name
      t.string :size
      t.integer :humps
    end
  end
end
