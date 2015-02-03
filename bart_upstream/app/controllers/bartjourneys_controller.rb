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

	def testme
		@bartjourney = test_program
	end


	private

    def bartjourney_params
      params.require(:bartjourney).permit(:start_station_id, :end_station_id, :user_id, :direction)
    end


end
