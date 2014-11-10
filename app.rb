require 'rack'
require 'erubis'


class Handler

  def initialize
    @data =  Hash.new {|hash,value| hash[value] = 0 }
  end

  def call(env)
    req = Rack::Request.new(env)

    case req.path
    # home page
    when '/'
      # 200 OK normal response
      response = ['200', {"Content-Type" => 'text/html'}, [render("index.erb", {data: @data.to_a})]]
    # 'remember-me' accepts form data
    when '/remember-me'
      name = req.params["name"]
      if name
        @data[name] += 1
      end
      # 302 Found: Redirect
      response = ['302', {'Content-Type' => 'text','Location' => '/'}, ['302 found'] ]
    when '/favicon.ico'
      # 403: Forbidden esponse code forces browsers to stop requesting favicons
      response = ['403', {}, ["Not going to happen."]]
    when '/styles.css'
      response = ['200', {'Content-Type' => 'text/css'}, [File.open("styles.css").read()]]
    # If all elsifs fail, return 404 Not Found
    else
      response = ['404', {'Content-Type' => 'text/html'}, ["<h1>Better luck next time.</h1>"]]
    end

    return response
    
  end

  def render(template, data)
    Erubis::Eruby.new(File.read(template)).result(data)
  end
  

end

app = Handler.new
Rack::Handler::WEBrick.run(app, Port: 8888)
