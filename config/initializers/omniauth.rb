options = {
  scope: "email, https://www.googleapis.com/auth/gmail.modify",
  :prompt => "select_account",
  access_type: 'offline',
  :client_options => {
    :ssl => {
      :ca_file => "/usr/local/etc/openssl/certs/ca-bundle.crt",
      :ca_path => "/usr/local/etc/openssl/certs"
    }
  }
}

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.secrets.client_id, Rails.application.secrets.client_secret, options
end
