class CreateFavorites < ActiveRecord::Migration[7.1]
  def change
    create_table :favorites do |t|
      t.string :favoritable_type
      t.integer :favoritable_id

      t.timestamps
    end
  end
end
