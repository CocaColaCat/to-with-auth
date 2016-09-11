class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader

  has_secure_password

  has_many :todos
end
