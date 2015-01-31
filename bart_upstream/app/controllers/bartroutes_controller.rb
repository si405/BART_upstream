class BartroutesController < ApplicationController
	include BartroutesHelper

	def index
		@bartroutes = Bartroute.all.order(:bart_route_id)
	end

	def new
		@bartroute = Bartroute.new
	end

	# Create a new route using the params provided from 
	# the view and redirect back to the main index page
	def create
		@bartroute = Bartroute.new(bartroute_params)
		if @bartroute.save
			flash[:success] = "Route created"
			redirect_to bartroutes_path 
		else
			flash[:error] = "Unable to save route. Please try again"
			render :create
		end
	end

	def seed_bart_routes
		load_bart_routes
		redirect_to bartroutes_path
	end

	def unseed_bart_routes
		remove_bart_routes
		redirect_to bartroutes_path
	end

	private

	def bartroute_params
		params.require(:bart_route_name, :bart_route_color, :bart_route_short_name, :bart_route_id, 
			:bart_route_number).permit(:bart_route_name, :bart_route_color, :bart_route_short_name, :bart_route_id, 
			:bart_route_number)
	end
end
