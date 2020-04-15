with import <nixpkgs> { };

let
  mapDeps = map (x: ''
    mkdir -p deps
    cp -r --no-preserve=mode,ownership '${x.src}' 'deps/${x.name}'
  '');
  deps = callPackage ./deps.nix { };
in stdenvNoCC.mkDerivation rec {
  pname = "unixbot";
  version = "0.1.0";

  src = nix-gitignore.gitignoreSourcePure [ ./.gitignore ] ./.;

  buildInputs = [ elixir beamPackages.hex rebar3 ];

  setupHook = writeText "setupHook.sh" ''
    addToSearchPath ERL_LIBS "$1/lib/erlang/lib"
  '';

  configurePhase = ''
    mkdir -p deps
    ${lib.concatStringsSep "\n" (mapDeps deps)}
  '';

  buildPhase = ''
    export HEX_OFFLINE=1
    export HEX_HOME=`pwd`
    export MIX_HOME=`pwd`
    export MIX_ENV=prod
    export MIX_NO_DEPS=1
    ln -s ${rebar3}/bin/rebar rebar
    ln -s ${rebar3}/bin/rebar3 rebar3

    mix deps.compile
    MIX_ENV=prod mix release --no-deps-check --overwrite
  '';

  installPhase = ''
    mkdir -p $out
    tar xvf _build/prod/unixbot-${version}.tar.gz -C $out
  '';
}
