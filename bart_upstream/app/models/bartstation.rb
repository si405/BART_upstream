class Bartstation < ActiveRecord::Base

	has_many :bartroutestation

    validates :station_name, :presence => true
    validates :short_name, :presence => true
    validates :gtfs_latitude, :presence => true
    validates :gtfs_longitude, :presence => true
    validates :address, :presence => true
    validates :string, :presence => true
    validates :city, :presence => true
    validates :county, :presence => true
    validates :state, :presence => true
    validates :zipcode, :presence => true
 
end
