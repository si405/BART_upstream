class CreateBartjourneys < ActiveRecord::Migration
  def change
    create_table :bartjourneys do |t|
    	t.references	:start_station
    	t.references	:end_station
    	t.references	:user, column_options: {null: true}
      	t.timestamps
    end
  end
end