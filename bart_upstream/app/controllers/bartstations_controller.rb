class BartstationsController < ApplicationController
	include BartstationsHelper

	def index
		@bartstations = Bartstation.all
	end

	def new
		@bartstation = Bartstation.new
	end

	def create
		# Create a new post using the params provided from 
		# the view and redirect back to the main index page
		@bartstation = Bartstation.new(station_params)
		if @bartstation.save
			flash[:success] = "Station created"
			redirect_to bartstations_path 
		else
			flash[:error] = "Unable to save station. Please try again"
			render :create
		end
	end

	def show
		@bartstations = Bartstation.all
	end

	def seed_bart_stations
		# Seed the database with the station details downloaded from the BART API
		load_bart_station_names
		redirect_to bartstations_path
	end

	def unseed_bart_stations
		# Remove all the stations from the database
		remove_bart_station_names
		redirect_to bartstations_path
	end

	def source
		# Check the direction of travel. N = normal direction, R = reverse
		if params["direction"] = "N"
			get_departure_times(params["start_station"],params["end_station"])
			binding.pry
		else
			binding.pry
		end
	end

	private

	def station_params
		params.require(:station_name, :short_name, :gtfs_latitude, :gtfs_longitude, 
			:address, :city, :county, :state, :zipcode).permit(:station_name, :short_name, 
			:gtfs_latitude, :gtfs_longitude, :address, :city, :county, :state, :zipcode)
	end


end
