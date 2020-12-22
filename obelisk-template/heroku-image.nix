{ dockerTag ? "latest", nixpkgs, exe, image-name }:

let

  # add config and static folders to the server derivation
  serverExe-config = nixpkgs.runCommand "serverExe-config"
                                {}
                                ''
                                  mkdir $out
                                  cp -r ${exe}/* $out
                                  cp -r ${../config} $out/config
                                  cp -r ${../static} $out/static
                                '';
  
  entrypoint = nixpkgs.writeScript "entrypoint.sh" ''
    #!${nixpkgs.stdenv.shell}
    $@ -p $PORT
  '';
in

  nixpkgs.dockerTools.buildImage {
    name = "${image-name}";
    tag = "${dockerTag}";
    config = {
      Env = [ "PORT=8000" ];
      WorkingDir = "${serverExe-config}/";
      Entrypoint = [ entrypoint ];
      Cmd = [ "./backend" ];

    };
  }