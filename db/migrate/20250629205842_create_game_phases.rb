class CreateGamePhases < ActiveRecord::Migration[8.0]
  def change
    create_table :game_phases do |t|
      t.string :phase
      t.string :community_cards, array: true, default: []
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
