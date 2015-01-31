class CreateBartroutes < ActiveRecord::Migration
  def change
    create_table :bartroutes do |t|
 	  t.string :bart_route_name
      t.string :bart_route_short_name
      t.string :bart_route_id
      t.integer :bart_route_number
      t.string :bart_route_color
      t.timestamps
    end
  end
end
