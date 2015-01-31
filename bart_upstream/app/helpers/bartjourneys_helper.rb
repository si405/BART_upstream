module BartjourneysHelper

	# Get all the station names from the database

	def get_station_names_DB
		@allbartstations = Bartstation.all
		@bartstations = {}
		@allbartstations.each do |bartstation|
			@bartstations[bartstation.station_name] = 
					bartstation.id
		end
	
		return @bartstations
	end

	# Determine the schedule between the selected origin and 
	# destination stations. This is the main function.

	def calculate_bart_times(journeydetails)

		# Determine the start and end stations
		# Pluck returns an array so only the first element is populated and needed

		start_station_code = Bartstation.where("id = #{journeydetails.start_station_id}").pluck("short_name")[0]
		@start_station = Bartstation.where("id = #{journeydetails.start_station_id}").pluck("station_name")[0]
		end_station_code = Bartstation.where("id = #{journeydetails.end_station_id}").pluck("short_name")[0]
		@end_station = Bartstation.where("id = #{journeydetails.end_station_id}").pluck("station_name")[0]

		bartjourney_options = get_bart_schedule(start_station_code,end_station_code,@bartjourney.direction)

		# Return the results

		return bartjourney_options

	end

	# Get the schedule information between the origin and destination from the 
	# BART API. The origin and destination are passed in as arrays

	def get_bart_schedule(origin_station, destination_station, direction)

		response = Typhoeus.get("http://api.bart.gov/api/sched.aspx?cmd=depart&orig=#{origin_station}&dest=#{destination_station}&date=now&key=ZZLI-UU93-IMPQ-DT35")

		# Extract the station names and short names

		response_XML = Nokogiri.XML(response.body)

		# Create a hash list of the station names and abbreviations

		# Use a hash to store the route options to manage duplicate entries

		bartroute_options = {}
		feasible_train_options ={}
		upstream_station_codes	= {}

		response_XML.xpath("///trip").each do |node|
			
			# Check to see if any transfers are involved
			# *** IF SO DEAL WITH THOSE LATER ****


			if node['transfercode'] == nil

				# There is only one leg for this journey
				node.children.each do |leg|

					# Get the available bart routes from the "leg" of the journey

					bartroute_options[node.at('leg')['trainHeadStation']] = 
						node.at('leg')['trainHeadStation']
				
				end

			end

			# If the direction is "normal", loop through the route options and find the 
			# real time departures for each route option that originates from the origin 
			# station.
			# If the direction is "reverse", find the upstream stations and include the 
			# departures from those stations

			departure_times = {}
			departure_stations = []		

			if @bartjourney.direction == "Normal"
				bart_direction = nil
				departure_times = get_real_time_departures(origin_station,bart_direction)
				feasible_train_options = 
					filter_departures(departure_times,bartroute_options)
			else
				
				# *** For now assume that reverse = southbound for testing upstream at ***
				# *** SF stations ***
				
				bart_direction = 's'
				
#				# Find the departure times from the current station heading in the 
#				# reverse direction
#				
#				origin_departure_times = get_real_time_departures(origin_station,bart_direction)
				
				# For the reverse direction find the upstream stations on each route
				# serving the origin station. The returned hash has each upstream 
				# bartroutestation including the origin station
				
				departure_stations = get_upstream_stations(origin_station)
				
				# For each route and upstream station found
				#     Find the departure times from each of those stations
				# 	  Due to the BART API it's necessary to retrieve all departures
				#     in the selected direction and then filter the results

				upstream_departure_times = {}
				departure_stations.each do |bartroute, upstream_stations|
					upstream_stations.each do |departure_station|
						
						# The array contains the id of the station and the API needs the short name
						start_station_code = Bartstation.where("id = #{departure_station.bartstation_id}").pluck("short_name")[0]
						
						# Get the departure times for the upstream station in the selected
						# direction

						upstream_departure_times[start_station_code] = 
							get_real_time_departures(start_station_code,bart_direction)
						
						upstream_station_codes[start_station_code] = departure_station.bartstation_id

					end
				end

				# 2015-01-30 CODE CUT 1 FROM HERE -----

				# 2015-01-30 CODE CUT 1 TO HERE -----

				# For each upstream station find the northbound departures for each of those
				# stations. Since the destination cannot be specified in the BART API it's
				# necessary to get all trains and then filter the results

				upstream_destination_departure_times = {}
				departure_stations.each do |bartroute, upstream_stations|
					upstream_stations.each do |departure_station|
						
						# The array contains the id of the station and the API needs the short name
						start_station_code = Bartstation.where("id = #{departure_station.bartstation_id}").pluck("short_name")[0]
						
						# Get the departure times for the upstream station in the northbound 
						# direction

						bart_direction = 'n'

						departure_times = []
						departure_times = get_real_time_departures(start_station_code,bart_direction)
						
						# The API returns all the departures from this station.
						# Filter the results to only get those trains that are destined for the
						# destination 

						upstream_destination_departure_times[start_station_code] =
								filter_departures(departure_times,bartroute_options)
					end
				end

				# Align the departures from the origin station with the departures
				# from the upstream stations to show feasible train options

				# 2015-01-30 CODE CUT 2 FROM HERE -----

				# 2015-01-30 CODE CUT 2 TO HERE -----
			
				feasible_train_options = 
					determine_feasible_trains(origin_station,upstream_departure_times,upstream_destination_departure_times)
			end
		end

		# Sort the feasible train options hash in order of upstream station
		# The hash upstream_station_codes holds the upstream stations in order



		binding.pry

		return feasible_train_options
	end

	# Use the departure station to get the real-time departures from that station
	# There will be trains to other destinations and these will be filtered later
	# as there is no way to request real-time data from the origin station to the 
	# destination station

	def get_real_time_departures(origin_station,direction)

		# Set up the hash to store the departure options for this destination

		if direction == nil
			direction_string = nil
		else
			direction_string = "dir=#{direction}&"
		end

		response = Typhoeus.get("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{origin_station}&#{direction_string}key=ZZLI-UU93-IMPQ-DT35")

		# Extract the station names and short names

		response_XML = Nokogiri.XML(response.body)

		# Create a hash list of the station names and abbreviations
		# node provides the full name of the station and next node is 
		# the abbreviation


		departure_options = {}

		i = 0

		response_XML.xpath("///etd").each do |node|

			# Process the children of each destination node to get the times

			departure_times = []
			current_station = node.css('abbreviation').text
			
			j = 0

			node.css('minutes').each do |departure|
				
				# Ignore any trains that are already leaving
				if departure.text != "Leaving"
					departure_times[j] = departure.text
					j = j + 1
				end

			end

			departure_options[current_station] = departure_times

			i = i + 1

		end

		return departure_options

	end

	# This function gets passed a list of the real-time departures and the list of possible 
	# routes between the origin and destination. It filters out the real-time departures for 
	# the possible routes.

	def filter_departures(departure_times,bartroute_options)
		# Filter the results of the real-time departures to find those that match the 
		# route options. 

		filtered_departure_times = {}

		departure_times.each do |station,times|
			bartroute_options.each do |bartroute_station,v|
				if station == bartroute_station
					station_name = Bartstation.where("short_name = '#{bartroute_station}'").pluck("station_name")[0]
					filtered_departure_times[station_name] = times
				end
			end
		end

		return filtered_departure_times
	end

	# Find the upstream stations from the origin station 
	def get_upstream_stations(origin_station)
		
		starting_station = Bartstation.where("short_name = '#{origin_station}'").pluck("id")[0]
		
		# Find all the instances of the starting station
		# The station may appear on multiple routes
		
		station_routes = {}
		
		Bartroutestation.where("bartstation_id = #{starting_station}").each do |routestation|
				station_routes[routestation.bartroute_id] = routestation.route_station_sequence
		end

		# For each route that has the starting station:
		#      Find the starting station 
		#      Find the next 5 stations in the reverse direction
		#      (The stations are sequenced in the database to increment from the east 
		#      bay direction)

		upstream_stations = {}
		station_routes.each do |station_route,station_sequence|
			bartroute_id = station_route
			bartstation_sequence = station_sequence			
			upstream_stations[bartroute_id] = 
				Bartroutestation.where("bartroute_id = #{bartroute_id} AND 
					route_station_sequence >= #{bartstation_sequence}").order('route_station_sequence').take(6)
		end

		# Return the list of upstream stations for each route from the origin station

		return upstream_stations

	end

	def determine_feasible_trains(origin_station,origin_trains,destination_trains)
		# Compare the arrival times at each upstream station with the departure times to 
		# the desired destination. If the train arrives before the destination train is 
		# departing then it is a valid option 

		possible_trains = {}
		valid_trains = {}
		valid_train = {}
		train_options = {}
		train_id = {}

		# Process all departures from the origin station
		origin_trains[origin_station].each do |destination, departure_times|
			departure_train_sequence = 0
			departure_times.each do |departure_time|
				latest_departure_time = departure_time.to_i
				train_id = [destination, departure_time]
				valid_trains[origin_station] = departure_time
				origin_trains.each do |departure_station, destination_details|
					if departure_station != origin_station
						# This is an upstream station
						destination_details.each do |train_destination,departure_times_from_next_station|
							if train_destination == destination
								# This train is going to the same destination
								if departure_times_from_next_station[departure_train_sequence].to_i >=
									latest_departure_time.to_i
									# This train leaves the upstream station later than the prior
									# station and is therefore part of the same journey
									valid_trains[departure_station] = 
										departure_times_from_next_station[departure_train_sequence]
									latest_departure_time = 
										departure_times_from_next_station[departure_train_sequence]
								end
							end

						end
					end
				end
				# At this point we have processed all the upstream stations for this 
				# particular origin train departure time

				train_options[train_id] = valid_trains
				departure_train_sequence = departure_train_sequence + 1
				valid_trains = {}
			end
		end
	
		
		# We have the schedule for each train departing the origin station and when it leaves
		# each upstream station so now we can calculate which of the destination trains we can 
		# meet at each station

		train_options.each do |train, train_times|
			train_times.each do |arrival_station, arrival_time|
				if arrival_station != origin_station
					# Ignore the entry for the origin station. This is only used in the 
					# display. Find all the destination trains that this train can meet 
					# at this station
					destination_trains[arrival_station].each do |train_destination, destination_times|
						destination_times.each do |destination_departure_time|
							if destination_departure_time.to_i >= arrival_time.to_i
								# The destination train leaves after this train arrives
								train_id = [arrival_station,destination_departure_time]
								valid_trains[train_id] = train_destination
							end
						end
					end
					# All the destination train departures for this station have been processed
					# so write the options to the hash
				end
			end
			possible_trains[train] = valid_trains
			valid_trains = {}
		end 
		return possible_trains
	end

	def test_program
		# Sort the hash to return the chronological options for each departing train

		feasible_train_options = 
			 {["DALY", "3"]=>
			  {["MONT", "11"]=>"Pittsburg/Bay Point",
			   ["MONT", "24"]=>"Pittsburg/Bay Point",
			   ["MONT", "36"]=>"Pittsburg/Bay Point",
			   ["POWL", "9"]=>"Pittsburg/Bay Point",
			   ["POWL", "23"]=>"Pittsburg/Bay Point",
			   ["POWL", "35"]=>"Pittsburg/Bay Point",
			   ["CIVC", "7"]=>"Pittsburg/Bay Point",
			   ["CIVC", "21"]=>"Pittsburg/Bay Point",
			   ["CIVC", "33"]=>"Pittsburg/Bay Point"},
			 ["DALY", "9"]=>
			  {["MONT", "11"]=>"Pittsburg/Bay Point",
			   ["MONT", "24"]=>"Pittsburg/Bay Point",
			   ["MONT", "36"]=>"Pittsburg/Bay Point",
			   ["POWL", "23"]=>"Pittsburg/Bay Point",
			   ["POWL", "35"]=>"Pittsburg/Bay Point",
			   ["CIVC", "21"]=>"Pittsburg/Bay Point",
			   ["CIVC", "33"]=>"Pittsburg/Bay Point"},
			 ["DALY", "17"]=>
			  {["MONT", "24"]=>"Pittsburg/Bay Point",
			   ["MONT", "36"]=>"Pittsburg/Bay Point",
			   ["POWL", "23"]=>"Pittsburg/Bay Point",
			   ["POWL", "35"]=>"Pittsburg/Bay Point",
			   ["CIVC", "33"]=>"Pittsburg/Bay Point"},
			 ["MLBR", "13"]=>{["MONT", "24"]=>"Pittsburg/Bay Point", ["MONT", "36"]=>"Pittsburg/Bay Point"},
			 ["MLBR", "28"]=>{["MONT", "36"]=>"Pittsburg/Bay Point"},
			 ["MLBR", "43"]=>{},
			 ["SFIA", "6"]=>
			  {["MONT", "11"]=>"Pittsburg/Bay Point",
			   ["MONT", "24"]=>"Pittsburg/Bay Point",
			   ["MONT", "36"]=>"Pittsburg/Bay Point",
			   ["POWL", "9"]=>"Pittsburg/Bay Point",
			   ["POWL", "23"]=>"Pittsburg/Bay Point",
			   ["POWL", "35"]=>"Pittsburg/Bay Point",
			   ["CIVC", "21"]=>"Pittsburg/Bay Point",
			   ["CIVC", "33"]=>"Pittsburg/Bay Point",
			   ["16TH", "19"]=>"Pittsburg/Bay Point",
			   ["16TH", "31"]=>"Pittsburg/Bay Point",
			   ["24TH", "17"]=>"Pittsburg/Bay Point",
			   ["24TH", "29"]=>"Pittsburg/Bay Point"},
			 ["SFIA", "11"]=>
			  {["MONT", "24"]=>"Pittsburg/Bay Point",
			   ["MONT", "36"]=>"Pittsburg/Bay Point",
			   ["POWL", "23"]=>"Pittsburg/Bay Point",
			   ["POWL", "35"]=>"Pittsburg/Bay Point",
			   ["CIVC", "21"]=>"Pittsburg/Bay Point",
			   ["CIVC", "33"]=>"Pittsburg/Bay Point",
			   ["16TH", "19"]=>"Pittsburg/Bay Point",
			   ["16TH", "31"]=>"Pittsburg/Bay Point",
			   ["24TH", "29"]=>"Pittsburg/Bay Point"},
			 ["SFIA", "21"]=>
			  {["MONT", "24"]=>"Pittsburg/Bay Point",
			   ["MONT", "36"]=>"Pittsburg/Bay Point",
			   ["POWL", "35"]=>"Pittsburg/Bay Point",
			   ["CIVC", "33"]=>"Pittsburg/Bay Point",
			   ["16TH", "31"]=>"Pittsburg/Bay Point"}}

		feasible_train_options.each do |train,departure_options|
			i = 0
			departure_options.each do |departure_details, destination|
				if i == 0
					# First entry for this train
				end
				
			end
		end

	end

	def test_program2
	# Test program to process hash

		origin_trains = {"EMBR"=>{"DALY"=>["1", "5", "9"], "MLBR"=>["7", "20", "35"], "SFIA"=>["14", "27", "42"]},
		 "MONT"=>{"DALY"=>["3", "6", "10"], "MLBR"=>["8", "21", "36"], "SFIA"=>["15", "29", "44"]},
		 "POWL"=>{"DALY"=>["5", "7", "12"], "MLBR"=>["10", "23", "38"], "SFIA"=>["17", "30"]},
		 "CIVC"=>{"DALY"=>["6", "9", "14"], "MLBR"=>["11", "24", "39"], "SFIA"=>["2", "18", "32"]},
		 "16TH"=>{"DALY"=>["1", "8", "11"], "MLBR"=>["13", "26", "41"], "SFIA"=>["4", "21", "34"]},
		 "GLEN"=>{"DALY"=>["2", "6", "14"], "MLBR"=>["4", "18", "31"], "SFIA"=>["9", "26", "39"]}}

		# This is the hash upstream_destination_departure_times
		destination_trains = {"EMBR"=>{"Pittsburg/Bay Point"=>["2", "18", "31"]},
		 "MONT"=>{"Pittsburg/Bay Point"=>["16", "30"]},
		 "POWL"=>{"Pittsburg/Bay Point"=>["14", "28", "43"]},
		 "CIVC"=>{"Pittsburg/Bay Point"=>["13", "27", "42"]},
		 "16TH"=>{"Pittsburg/Bay Point"=>["11", "25", "40"]},
		 "GLEN"=>{"Pittsburg/Bay Point"=>["6", "20", "35"]}}


		origin_station = "EMBR"
		possible_trains = {}
		valid_trains = {}
		valid_train = {}
		train_options = {}
		train_id = {}

		# Process all departures from the origin station
		origin_trains[origin_station].each do |destination, departure_times|
			departure_train_sequence = 0
			departure_times.each do |departure_time|
				latest_departure_time = departure_time.to_i
				train_id = [destination, departure_time]
				valid_trains[origin_station] = departure_time
				origin_trains.each do |departure_station, destination_details|
					if departure_station != origin_station
						# This is an upstream station
						destination_details.each do |train_destination,departure_times_from_next_station|
							if train_destination == destination
								# This train is going to the same destination
								if departure_times_from_next_station[departure_train_sequence].to_i >=
									latest_departure_time.to_i
									# This train leaves the upstream station later than the prior
									# station and is therefore part of the same journey
									valid_trains[departure_station] = 
										departure_times_from_next_station[departure_train_sequence]
									latest_departure_time = 
										departure_times_from_next_station[departure_train_sequence]
								end
							end

						end
					end
				end
				# At this point we have processed all the upstream stations for this 
				# particular origin train departure time

				train_options[train_id] = valid_trains
				departure_train_sequence = departure_train_sequence + 1
				valid_trains = {}
			end
		end
	
		
		# We have the schedule for each train departing the origin station and when it leaves
		# each upstream station so now we can calculate which of the destination trains we can 
		# meet at each station

		train_options.each do |train, train_times|
			train_times.each do |arrival_station, arrival_time|
				if arrival_station != origin_station
					# Ignore the entry for the origin station. This is only used in the 
					# display. Find all the destination trains that this train can meet 
					# at this station
					destination_trains[arrival_station].each do |train_destination, destination_times|
						destination_times.each do |destination_departure_time|
							if destination_departure_time.to_i >= arrival_time.to_i
								# The destination train leaves after this train arrives
								train_id = [arrival_station,destination_departure_time]
								valid_trains[train_id] = train_destination
							end
						end
					end
					# All the destination train departures for this station have been processed
					# so write the options to the hash
				end
			end

			possible_trains[train] = valid_trains
			valid_trains = {}
		
		end 

		binding.pry

		return possible_trains

	end

end