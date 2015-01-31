class CreateBartroutestations < ActiveRecord::Migration
  def change
    create_table :bartroutestations do |t|
      t.references :bartstation, index: true
      t.references :bartroute, index: true
      t.integer :route_station_sequence
      t.timestamps
    end
  end
end
