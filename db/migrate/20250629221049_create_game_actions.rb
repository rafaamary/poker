class CreateGameActions < ActiveRecord::Migration[8.0]
  def change
    create_table :game_actions do |t|
      t.string :action
      t.references :player, null: false, foreign_key: true
      t.references :game_phase, null: false, foreign_key: true
      t.integer :pot

      t.timestamps
    end
  end
end
