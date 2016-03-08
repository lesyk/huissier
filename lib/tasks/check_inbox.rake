def get_details(id)
  client = Google::APIClient.new
  client.authorization.access_token = Token.last.fresh_token
  service = client.discovered_api('gmail')
  result = client.execute(
    :api_method => service.users.messages.get,
    :parameters => {'userId' => 'me', 'id' => id},
    :headers => {'Content-Type' => 'application/json'})
  data = JSON.parse(result.body)

  puts "Letter ID: " + id
  puts "Subject: " + get_gmail_attribute(data, 'Subject')
  puts "From: " + get_gmail_attribute(data, 'From')
  puts "Files: "
    get_files(data, id)
end

def get_gmail_attribute(gmail_data, attribute)
  headers = gmail_data['payload']['headers']
  array = headers.reject { |hash| hash['name'] != attribute }
  array.first['value']
end

def get_files(gmail_data, messageId)
  client = Google::APIClient.new
  client.authorization.access_token = Token.last.fresh_token
  service = client.discovered_api('gmail')

  for file in gmail_data['payload']['parts'] do
    attachmentId = file['body']['attachmentId']
    filename = file['filename']
    if filename && attachmentId
      puts filename + ": " + attachmentId

      result = client.execute(
        :api_method => service.users.messages.attachments.get,
        :parameters => {'userId' => 'me', 'messageId' => messageId, 'id' => attachmentId},
        :headers => {'Content-Type' => 'application/json'}
      )

      response_json = JSON.parse(result.body)
      file = File.new(Rails.root+'/files/'+filename, 'wb')
      file.write Base64.urlsafe_decode64(response_json['data'].encode('UTF-8'))
      file.close
    end
  end
end

# TODO: look for Boarding pass words in pdfs

task :check_inbox => :environment do
  client = Google::APIClient.new
  client.authorization.access_token = Token.last.fresh_token
  service = client.discovered_api('gmail')
  result = client.execute(
    :api_method => service.users.messages.list,
    :parameters => {'userId' => 'me', 'q' => 'has:attachment', 'maxResults'=>10},
    :headers => {'Content-Type' => 'application/json'})
  messages = JSON.parse(result.body)['messages'] || []
  messages.each do |msg|
    get_details(msg['id'])
  end
end
