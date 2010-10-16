require 'rubygems'
require 'sinatra/base'
require 'haml'

class DistributedShelfExample < Sinatra::Base

  configure :production do
    require 'dshelf'
    DistributedShelf::config = {
      :distributed_path => 'upload',
      :storage_url => ENV['DISTRIBUTED_SHELF_URL']
    }
  end

  get '/' do
    haml <<-hml
%form(action="/upload" method="post" enctype="multipart/form-data")
  %input(type="file" name="file")
  %input(type="submit" value="Upload")
  %span
    env is:
    =ENV['DISTRIBUTED_SHELF_URL']
    =ENV
    hml
  end

  post '/upload' do
    if params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
      path = File.join('upload', name)
      File.open(path, "wb") { |f| f.write(tmpfile.read) }
    end
    redirect '/'
  end

end
