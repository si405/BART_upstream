class BartjourneysController < ApplicationController
	include BartjourneysHelper

	def new
		@bartstations = get_station_names_DB
		@bartjourney = Bartjourney.new
	end

	# Create a new journey using the params provided from 
	# the view and redirect back to the main index page
	def create
		@bartjourney = Bartjourney.new(bartjourney_params)
#		if user_signed_in?
#			@bartjourney.user_id = current_user.user_id
#		end

		# Save the journeys for analytics
		if @bartjourney.save
			flash[:success] = "Journey created"
			redirect_to bartjourney_path(@bartjourney)
		else
			flash[:error] = "Unable to save journey. Please try again"
			render :create
		end
	end

	def show
		@bartjourney = Bartjourney.find(params[:id])
		@bartjourney_direction = @bartjourney.direction
		@bartjourney_options = calculate_bart_times(@bartjourney)
		return @bartjourney_options, @bartjourney_direction
	end

	def sms
		# Get your Account Sid and Auth Token from twilio.com/user/account
		account_sid = 'PN0cb7e951004cf11c976200617361437f'
		auth_token = ''
		@client = Twilio::REST::Client.new account_sid, auth_token

		message_body = params["Body"]
    	from_number = params["From"]

    	
    	# Parse the message body to get the origin and destination stations. Origin is considered
    	# to be the first station code, destination the second.
    	# The 3rd field represents the direction n = normal, r = reverse, nothing defaults to reverse
    	
    	sms_message_array = []

    	# For testing, assume certain stations if not invoked via Twilio

    	if message_body != nil
	    	sms_message_array = message_body.split
	    	sms_message_array[0] = sms_message_array[0].upcase
	    	sms_message_array[1] = sms_message_array[1].upcase
	    else
	    	sms_message_array[0] = "EMBR"
	    	sms_message_array[1] = "CONC"
	    	sms_message_array[2] = "Reverse"
	    end

    	# Get the short codes from the database to verify the stations
    	station_codes = get_station_codes_DB

    	start_station = nil
    	start_station_id = nil
    	end_station = nil
    	end_station_id = nil
    	direction = nil

    	i = 0 
    	if sms_message_array != nil
	    	sms_message_array.each do |sms_entry|
	    		if station_codes.include?(sms_entry)
	    			if i == 0 
	    				start_station = sms_entry
	    				i = i + 1
	    			elsif i == 1
	    				end_station = sms_entry
	    				i = i + 1
	    			elsif i > 1
	    				if sms_entry == ('n' or 'N')
	    					direction = 'Normal'
	    				else
	    					direction = 'Reverse'
	    				end
	    			end
	    		end
	    	end

	    	# Get the station IDs for the selected stations
	    	# Searching the hash using "hash.key" didn't work. Revisit later
	    	station_codes.each do |station_code,station_id|
		    	if station_code == start_station
		    		start_station_id = station_id
		    	end
		    	if station_code == end_station
		    		end_station_id = station_id
		    	end
		    end

		    # Create the Bartjourney entry

		    @bartjourney = Bartjourney.new
		    @bartjourney.start_station_id = start_station_id
		    @bartjourney.end_station_id = end_station_id
		    @bartjourney.direction = direction

#			if user_signed_in?
#				@bartjourney.user_id = current_user.user_id
#			end

			# Save the journeys for analytics
			if @bartjourney.save
				# Get the route information
				@bartjourney_direction = @bartjourney.direction
				@bartjourney_options = calculate_bart_times(@bartjourney)
				
				# Find the furthest you can travel for each train
				# Destination[1] is the station code, 2 is the time and 3 is the 
				# final destination of the train
				
				@train_response = {}
				latest_time = 100
				furthest_station = ""
				furthest_destination = ""

				# Find the furthest stations for each train by comparing the departure
				# times. Once the departure time at a station is greater than the prior
				# station this indicates that the furthest station is the prior one as
				# departure times are in descending order
				
				@bartjourney_options.each do |train_destination,train_details|
					latest_time = 100
					train_details.each do |station,destination|
						if station[3].to_i > latest_time.to_i
							break
						else
							latest_time = station[3]
							furthest_station = station[2]
							furthest_destination = destination
						end
					end
					if latest_time != 100
						@train_response[train_destination] = 
							[furthest_station,latest_time,furthest_destination]
					end
				end

				# Format the results to send back via SMS
				# {["SFIA", 2]=>["MONT", 3, "PITT"], ["DALY", 4]=>["16TH", 11, "PITT"]}

				sms_message = ""
				@train_response.each do |departing_train, furthest_station|
					sms_message = sms_message + "#{departing_train[0]} train in #{departing_train[1]} min to #{furthest_station[0]} meets #{furthest_station[2]} in #{furthest_station[1]} mins "
				end

				# Send the information back via SMS
				twiml = Twilio::TwiML::Response.new do |r|
    				r.Message "#{sms_message}"
  				end
  				render :text => twiml.text 			    	
 			end
 		end
	end

	def testme
		@bartjourney = test_program
	end


	private

    def bartjourney_params
      params.require(:bartjourney).permit(:start_station_id, :end_station_id, :user_id, :direction)
    end


end
