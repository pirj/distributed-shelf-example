require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'mime/types'

class DistributedShelfExample < Sinatra::Base

  configure do #:production 
ENV['DISTRIBUTED_SHELF_URL'] = 'http://localhost:8000/storage/3470e95cc331a9f9eea163f5f41e9483'

    require 'dshelf'
    DistributedShelf::config = {
      :distributed_path => 'upload',
      :storage_url => ENV['DISTRIBUTED_SHELF_URL']
    }
  end

  get '/' do
    hml = <<-hml
%form(action="/upload" method="post" enctype="multipart/form-data")
  %input(type="file" name="file")
  %input(type="submit" value="Upload")
- files.each do |file|
  %p
    %a(href=file)=file
    hml
    files = Dir.entries('upload')
    haml hml, :locals => {:files => files}
  end

  get '/:file' do
    filename = params[:file]
    attachment filename
    content_type MIME::Types.type_for(filename)
    File.open(File.join('upload', filename)).read
  end

  post '/upload' do
    if params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
      path = File.join('upload', name)
      File.open(path, "wb") { |f| f.write(tmpfile.read) }
    end
    redirect '/'
  end
end
