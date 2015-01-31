class CreateUsertypes < ActiveRecord::Migration
  def change
    create_table :usertypes do |t|
      t.string :user_type
      t.boolean :is_admin, :default => 'N'
      t.timestamps
    end
  end
end
