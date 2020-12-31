import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

database_pool_size = String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

http_port = String.to_integer(System.get_env("PORT") || "4000")

http_url_hostname =
  System.get_env("HOSTNAME") ||
    raise """
    environment variable HOSTNAME is missing.
    """

http_url_port = String.to_integer(System.get_env("URL_PORT", "80"))

config :website, Website.Repo, url: database_url, pool_size: database_pool_size

config :website, WebsiteWeb.Endpoint,
  secret_key_base: secret_key_base,
  http: [port: http_port, transport_options: [socket_opts: [:inet6]]],
  url: [host: http_url_hostname, port: http_url_port]
