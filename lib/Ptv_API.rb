module PtvAPI

	require 'base64'
	require 'json'
	require 'net/http'
	require 'openssl'


	def run(uri)
		data = parsed_json(execute(uri))
		data
	end

	def execute_json(uri)
		data = parsed_json(response)
		data
	end

	def parsed_json(response)
		JSON.parse(response)
	end

	def execute(uri)

		@devid = "3000522"
		@key = 	"9b321181-e0b4-4e9d-b08a-5af3d26bb6fc"

		digest = OpenSSL::Digest.new('sha1')
		signature = OpenSSL::HMAC.hexdigest(digest, @key, "#{uri}devid=#{@devid}")

		# test for route_types weirdness.
		signature.upcase!

		apiBase = "http://timetableapi.ptv.vic.gov.au";
		url = "#{apiBase}#{uri}devid=#{@devid}&signature=#{signature}"

p url

# URI needs the & or ? added to the end if there are no other query parameters
		response = Net::HTTP.get(URI(url))

# p response

		#Raw JSON
		response
	end
end