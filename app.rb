require 'thin'
require 'em-websocket'
require 'sinatra/base'

EM.run do
    class App < Sinatra::Base
        get '/' do
            erb :index
        end
    end

    @clients = []

    EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
       ws.onopen do |handshake|
            puts "WebSocket opened #{{
                :path => handshake.path,
                :query => handshake.query,
                :origin => handshake.origin,
            }}"
            @clients << ws
            ws.send "Connected to #{handshake.path}."
        end

        ws.onclose do
            ws.send "Closed."
            @clients.delete ws
            #EventMachine.stop
        end

        ws.onmessage do |msg|
            puts "Received Message: #{msg}"
            @clients.each do |socket|
                socket.send msg
            end
        end

        ws.onerror do |e|
            puts "Error: #{e.message}"
        end
    end

    App.run! :port => 3000
end
