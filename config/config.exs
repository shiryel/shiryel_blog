import Config

config :still,
  dev_layout: false,
  input: Path.join(Path.dirname(__DIR__), "priv/site"),
  output: Path.join(Path.dirname(__DIR__), "_site"),
  pass_through_copy: [~r|.*.min.js|, ~r|.*.min.css|, ~r|.*.xml|, ~r|.*.txt|]

import_config("#{Mix.env()}.exs")
