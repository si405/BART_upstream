class Bartjourney < ActiveRecord::Base
	belongs_to :start_station, :class_name => 'Bartstation'
  	belongs_to :end_station, :class_name => 'Bartstation'
  	has_many :Bartstation
end
