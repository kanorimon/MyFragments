class Tag < ActiveRecord::Base
  attr_accessible :memo_id, :name
  belongs_to :memo

  
end
