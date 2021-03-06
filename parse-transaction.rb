require 'dm-core'
require 'yaml'

opts = YAML.load_file(File.join(File.dirname(__FILE__), 'proxy.yml'))
DataMapper.setup :default, "sqlite://#{File.dirname(__FILE__)}/" + opts[:db]
# DataMapper.setup :default, "sqlite://#{Dir.pwd}/fhir-transactions.db"

class Request
  include DataMapper::Resource

  property :request_id, Serial
  property :request_method, String
  property :fhir_action, String
  property :request_uri, String
  property :remote_addr, String
  property :user_agent, String
  property :headers, String
  property :dt, DateTime
  property :data, String
end

class Response
  include DataMapper::Resource

  property :response_id, Serial
  property :request_id, String
  property :status, String
  property :headers, String
  property :dt, DateTime
  property :data, String
end
