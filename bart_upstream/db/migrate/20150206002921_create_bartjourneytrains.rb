class CreateBartjourneytrains < ActiveRecord::Migration
  def change
    create_table :bartjourneytrains do |t|
    	t.references :bartjourneys, index: true
    	t.string :train_destination
    	t.integer :train_departure_time
      	t.timestamps
    end
  end
end
