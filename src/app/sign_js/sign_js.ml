(* sign_js.ml *)

[%%import
"/src/config.mlh"]

[%%ifdef
consensus_mechanism]

[%%error
"sign_js cannot be built if \"consensus_mechanism\" is defined"]

[%%endif]

let sign = Coda_base_nonconsensus.User_command.sign
