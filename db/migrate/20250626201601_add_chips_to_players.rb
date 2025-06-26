class AddChipsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :chips, :integer, default: 1000, null: false
  end
end
