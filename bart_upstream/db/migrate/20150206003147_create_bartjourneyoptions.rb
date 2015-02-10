class CreateBartjourneyoptions < ActiveRecord::Migration
  def change
    create_table :bartjourneyoptions do |t|
	   	t.references :bartjourneytrains, index: true
	   	t.integer :train_number
	   	t.integer :station_number
	   	t.string :arrival_station
	   	t.integer :departure_time
	   	t.string :destination
	    t.timestamps
    end
  end
end
