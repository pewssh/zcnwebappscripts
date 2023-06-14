git clone https://github.com/0chain/onboarding-cli.git
cd onboarding-cli
go mod download
create config.yaml with below content
miners:
  - n2n_ip: localhost
    public_ip: localhost
    port: 5000
    description: random description


go run main.go generate-keys --signature_scheme bls0chain --miners 1 --sharders 0

go run main.go send-shares

go run main.go validate-shares


