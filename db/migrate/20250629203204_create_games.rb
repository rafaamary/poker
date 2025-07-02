urrclass CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.jsonb :initial_state
      t.references :room, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
