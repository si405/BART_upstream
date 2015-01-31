module BartroutestationsHelper

	def get_bart_station_pickers
		@bartroutestation = Bartroutestation.new
		@bartstations = Bartstation.all
		@bartstation_names = {}
		@bartstations.each do |bartstation|
			@bartstation_names[bartstation.station_name] = bartstation.id
		end 
		@bartroutes = Bartroute.all
		@bartroute_names = {}
		@bartroutes.each do |bartroute|
			@bartroute_names[bartroute.bart_route_name] = bartroute.id
		end 
	end

	# Remove all the station information from the database. Used in testing only
	def remove_all_bart_route_stations
		@stations = Bartroutestation.all
		@stations.each do |station|
			station.destroy
		end
	end

end
