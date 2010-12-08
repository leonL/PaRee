# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_PaRee_session',
  :secret      => '52bd02f387cffb45df5caa2599987a097bfef20e7b741b03bddd77fd97cee40fd9a383ee130afec7685218ec76a6a28578cf24cdd836470a2073f6691e91c6f4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
