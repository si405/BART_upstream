class AddDirectionToBartjourney < ActiveRecord::Migration
  def change
  	add_column :bartjourneys, :direction, :text, :default => 'Normal'
  end
end
