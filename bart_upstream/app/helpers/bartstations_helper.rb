module BartstationsHelper
# Helper functions for Stations

	# Get all the station names from the BART API
	# This will be changing to retrieve the list from the database to 
	# reduce the number of API calls

	def get_station_names

		# Typhoeus is used to submit http requests

		  response = Typhoeus.get("http://api.bart.gov/api/stn.aspx?cmd=stns&key=ZZLI-UU93-IMPQ-DT35")

		  # Extract the station names and short names

		  response_XML = Nokogiri.XML(response.body)

		  @station_names = {}

		  # Create a hash list of the station names and abbreviations
		  # node provides the full name of the station and next node is 
		  # the abbreviation

		  response_XML.xpath("//stations/station/name").each do |node|
#		  		@station_names[node.text] = node.next.text
				@station_names[response_XML.at_css('name').content] = 
					response_XML.at_css('abbr').content
		  		
		  end

		  return @station_names

	end

	# Get the trains departing from the selected departure station and 
	# determine which one goes to the selected destination.
	# For the first phase any train transfers will not be supported

	def get_departure_times(departure_station,destination_station)

		# Typhoeus is used to submit http requests

		  bart_url = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{departure_station}&key=ZZLI-UU93-IMPQ-DT35"

		  response = Typhoeus.get(bart_url)

		  # Extract the departure times to the chosen destination

		  response_XML = Nokogiri.XML(response.body)

		  @departure_times = {}

		  # Create a hash list of the departure times

		  response_XML.xpath("//station/etd/destination").each do |node|
		  		@departure_times[node.text] = node.next.text
		  		binding.pry
		  end

		  binding.pry

		  return @departure_times

	end

	# One-time population of the database with the station names from the BART API

	def load_bart_station_names

		# Typhoeus is used to submit http requests

		response = Typhoeus.get("http://api.bart.gov/api/stn.aspx?cmd=stns&key=ZZLI-UU93-IMPQ-DT35")

		# Extract the station names and short names and store them in the database

		response_XML = Nokogiri.XML(response.body)

		@station_names = {}

		response_XML.xpath("//stations/station").each do |node|
		  	@station = Bartstation.new
			@station.station_name = (node/'./name').text
			@station.short_name = (node/'./abbr').text
			@station.gtfs_latitude = (node/'./gtfs_latitude').text
  			@station.gtfs_longitude = (node/'./gtfs_longitude').text
  			@station.address = (node/'./address').text
  			@station.city = (node/'./city').text
  			@station.county = (node/'./county').text
  			@station.state = (node/'./state').text
  			@station.zipcode = (node/'./zipcode').text
			if @station.save
				flash[:success] = "Station #{@station.station_name} created" 
			else
				flash[:error] = "Unable to save station #{@station.station_name}. Please try again"
			end
		end
	end

	# Remove all the station information from the database. Used in testing only
	def remove_bart_station_names
		@stations = Bartstation.all
		@stations.each do |station|
			station.destroy
		end
	end
end
