# This test function processes the hash to get the correct departure time for a each train 
# from each upstream station.
# It works!

	def test_program
	# Test program to process hash

		origin_trains = {"EMBR"=>{"DALY"=>["1", "5", "9"], "MLBR"=>["7", "20", "35"], "SFIA"=>["14", "27", "42"]},
		 "MONT"=>{"DALY"=>["3", "6", "10"], "MLBR"=>["8", "21", "36"], "SFIA"=>["15", "29", "44"]},
		 "POWL"=>{"DALY"=>["5", "7", "12"], "MLBR"=>["10", "23", "38"], "SFIA"=>["17", "30"]},
		 "CIVC"=>{"DALY"=>["6", "9", "14"], "MLBR"=>["11", "24", "39"], "SFIA"=>["2", "18", "32"]},
		 "16TH"=>{"DALY"=>["1", "8", "11"], "MLBR"=>["13", "26", "41"], "SFIA"=>["4", "21", "34"]},
		 "GLEN"=>{"DALY"=>["2", "6", "14"], "MLBR"=>["4", "18", "31"], "SFIA"=>["9", "26", "39"]}}

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
				# particular origin train departure time. Write this information out as 
				# a schedule for this particular instance of a train, e.g. SFIA departing
				# EMBR in 1 minute departs MONT in 2 mins, POWL in 3 mins etc.

				train_options[train_id] = valid_trains
				departure_train_sequence = departure_train_sequence + 1
				valid_trains = {}
			end
		end

		return train_options

	end