class BartroutestationsController < ApplicationController

	include BartroutestationsHelper

	def index
		@bartroutestations = Bartroutestation.all.order('bartroute_id', 'route_station_sequence')
	end

	def new
		get_bart_station_pickers
		@bartroutestation = Bartroutestation.new
	end

	# Create a new route station association
	def create
 		@bartroutestation = Bartroutestation.new(bartroutestation_params)
		if @bartroutestation.save
			flash[:success] = "Route station created"
			redirect_to bartroutestations_path 
		else
			flash[:error] = "Unable to save route station. Please try again"
			get_bart_station_pickers
			render :new
		end
	end

	def edit
		get_bart_station_pickers
		@bartroutestation = Bartroutestation.find(params[:id])
	end

	# Update the modified route station and redirect back to the index
	def update
		@bartroutestation = Bartroutestation.find(params[:id])
#		@bartroutestation.route_station_sequence = (params['bartroutestation']['route_station_sequence'])
		if @bartroutestation.update(bartroutestation_params)
			flash[:success] = "Route station updated"
			redirect_to bartroutestations_path
		else
			render :edit
		end
	end

	def remove_bart_route_stations
		remove_all_bart_route_stations
		redirect_to bartroutestations_path
	end

	private

    def bartroutestation_params
      params.require(:bartroutestation).permit(:bartroute_id, :bartstation_id,:route_station_sequence)
    end

end
