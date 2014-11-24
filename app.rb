require 'rack'
require 'erubis'

class IPRecorder
  
  def initialize
    @data = Hash.new
  end

  def record(name, ip)
    if name
      @data[name] = ip
    end
  end

  def to_a
    @data.to_a
  end
  
end

class Handler

  def initialize
    @model = IPRecorder.new
  end

  def call(env)
    req = Rack::Request.new(env)
    
    case req.path
    # home page
    when '/'
      # 200 OK normal response
      response = ['200', {"Content-Type" => 'text/html'}, [render("index.erb", {data: @model.to_a})]]
    # 'remember-me' accepts form data
    when '/hello'
      # 200 OK normal response
      response = ['200', {"Content-Type" => 'text/html'}, ["Hello yourself."]]
    when '/remember-me'
      name = req.params["name"]
      @model.record(name, req.ip)
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
