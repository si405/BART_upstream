class CreateBartstations < ActiveRecord::Migration
  def change
    create_table :bartstations do |t|
		t.string :station_name
    	t.string :short_name
    	t.float :gtfs_latitude
  		t.float :gtfs_longitude
  		t.string :address, :string
  		t.string :city, :string
  		t.string :county, :string
  		t.string :state, :string
  		t.string :zipcode, :string
      	t.timestamps
    end
  end
end
