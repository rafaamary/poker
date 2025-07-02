class AddColumnPotToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :pot, :integer, default: 0, null: false
  end
end
