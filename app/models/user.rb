class User < ApplicationRecord
  validates_uniqueness_of :record_id
  
  has_many :faxes
end
