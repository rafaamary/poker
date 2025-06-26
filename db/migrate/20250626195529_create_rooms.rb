class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :max_players
      t.jsonb :current_players, array: true, default: []

      t.timestamps
    end
  end
end
