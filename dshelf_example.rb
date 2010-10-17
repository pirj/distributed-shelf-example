require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'mime/types'

class DistributedShelfExample < Sinatra::Base

  configure :production do
    require 'dshelf'
    DistributedShelf::config = {
      :distributed_path => 'upload',
      :storage_url => ENV['DISTRIBUTED_SHELF_URL']
    }
  end

  get '/' do
    hml = <<-'hml'
%form(action="/upload" method="post" enctype="multipart/form-data")
  %input(type="file" name="file")
  %input(type="submit" value="Upload")
- files.each do |file|
  %p
    %a(href="download/#{file}")=file
    hml
    files = begin Dir.entries('upload') rescue [] end
    haml hml, :locals => {:files => files}
  end

  get '/download/:file' do
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
