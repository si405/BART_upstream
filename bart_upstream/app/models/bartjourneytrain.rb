class Bartjourneytrain < ActiveRecord::Base

  belongs_to :bartjourney
  has_many :bartjourneyoption
   

end

