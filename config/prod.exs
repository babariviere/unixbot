import Config

config :logger,
  level: :info,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

config :nostrum,
  num_shards: :auto

config :unixbot,
  emotes: [
    "monkeyEuhh:616348820158152764",
    "soral:288737060146249728",
    "soralBof:585751521199915008",
    "RockNotBad:652424828413804554",
    "etchebestOof:613804706984099916",
    "kemarMind:587655590344654849",
    "NotLikeNoot:648522587369897994",
    "hype:47340152364544820",
    "spicyOil:357228612547641344",
    "pepeJail:585750407947747328"
  ]
