class Bartroutestation < ActiveRecord::Base
 
  belongs_to :bartstation
  belongs_to :bartroute

  validates :bartstation_id, :presence => true
  validates :bartroute_id, :presence => true
  validates :route_station_sequence, :presence => true
   
end
