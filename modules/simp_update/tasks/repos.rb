#!/usr/bin/ruby
#
# Puppet Task Name: simp_update::repos

require 'json'
require 'uri'
require 'excon'

def get(url, headers, *args)
  unless args.empty?
    url << "?#{args.join('&')}"
  end

  @cache = {} unless defined?(@cache)
  @connection = {} unless defined?(@connection)

  if @cache.key?(url)
    return @cache[url]
  end

  STDERR.puts "Fetching #{url}..."
  uri = URI(url)
  host = "#{uri.scheme}://#{uri.host}"
  path = url.delete_prefix(host)
  @connection[host] ||= Excon.new(host, persistent: true)
  response = @connection[host].get(path: path, headers: headers)
  info = JSON.parse(response.body)

  links = {}
  if response.headers[:link]
    response.headers[:link].scan(%r{<([^>]+)>;\s*rel="([^"]+)"}) do |m|
      links[m[1]] = m[0]
    end
  end

  if links['next']
    info.concat(get(links['next'], headers))
  end

  @cache[url] = info
end

params = JSON.parse(STDIN.read)

url = params['url'].nil? ? 'https://api.github.com/orgs/simp/repos' : params['url']

headers = {}
unless params['token'].nil?
  headers = { 'Authorization' => "token #{params['token']}" }
end

results = get(url, headers)

targets = {
  'value' => results.map do |result|
    if result['fork']
      info = get(result['url'], headers)
      result['parent'] = info['parent']
    end

    name = result.delete('name')

    result['path'] = File.expand_path(name, Dir.pwd)

    {
      'uri'    => "local://#{name}",
      'name'   => name,
      'vars'   => result,
      'config' => {
        'transport' => 'local',
      },
    }
  end,
}

targets['value'].reject! { |v| v['vars']['size'].zero? }
targets['value'].reject! { |v| v['vars']['archived'] }

puts targets.to_json
