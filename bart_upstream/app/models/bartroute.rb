class Bartroute < ActiveRecord::Base
	has_many :bartroutestation
	validates :bart_route_name, :presence => true
	validates :bart_route_name, :presence => true
	validates :bart_route_short_name, :presence => true
    validates :bart_route_id, :presence => true
    validates :bart_route_number, :presence => true
    validates :bart_route_color, :presence => true
end
