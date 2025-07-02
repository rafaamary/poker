class RenamePotToAmount < ActiveRecord::Migration[8.0]
  def change
    rename_column :game_actions, :pot, :amount
  end
end
