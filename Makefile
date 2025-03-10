GO_CMD = go
WGO_CMD = wgo
TEMPL_CMD = templ
WEBAPP_PATH = cmd/webapp/main.go
OUTPUT_BINARY = build/c1
PROTO_CMD = protoc

.PHONY: dev dev-templ dev-tailwind build-webapp

dev: 
	@echo "Running webapp in live mode..."
	@export $$(grep -v '^#' .env | xargs) && $(WGO_CMD) run $(WEBAPP_PATH)

dev-templ:
	@echo "Running templ in watch mode..."
	@$(TEMPL_CMD) generate --watch

build-webapp:
	@echo "Generating templates and building webapp..."
	@$(TEMPL_CMD) generate
	@CGO_ENABLED=0 $(GO_CMD) build -o $(OUTPUT_BINARY) $(WEBAPP_PATH)


proto:
	@echo "Generating protobufs..."
	$(PROTO_CMD) protoc --go_out=. --go-grpc_out=. ./proto/connector.proto   
