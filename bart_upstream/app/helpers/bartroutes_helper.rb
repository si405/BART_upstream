module BartroutesHelper

# Helper functions for Routes

	# One-time population of the database with the routes from the BART API

	def load_bart_routes

		response = Typhoeus.get("http://api.bart.gov/api/route.aspx?cmd=routes&key=ZZLI-UU93-IMPQ-DT35")

		# Extract the route details and store them in the database

		response_XML = Nokogiri.XML(response.body)

		@bartroutes = {}

		response_XML.xpath("//routes/route").each do |node|
		  	@bartroute = Bartroute.new
			@bartroute.bart_route_name = (node/'./name').text
			@bartroute.bart_route_short_name = (node/'./abbr').text
			@bartroute.bart_route_id = (node/'./routeID').text
  			@bartroute.bart_route_number = (node/'./number').text
  			@bartroute.bart_route_color = (node/'./color').text
 			if @bartroute.save
				flash[:success] = "Route #{@bartroute.bart_route_name} created" 
			else
				flash[:error] = "Unable to save route #{@bartroute.bart_route_name}. Please try again"
			end
		end
	end

	# Remove all the station information from the database. Used in testing only
	def remove_bart_routes
		@bartroutes = Bartroute.all
		@bartroutes.each do |bartroute|
			bartroute.destroy
		end
	end

end
