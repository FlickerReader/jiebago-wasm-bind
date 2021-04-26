build:
	GOOS=js GOARCH=wasm  go build  -o static/main.wasm .

package: build
	cp -f ./dict.txt ./static/dict.txt
	cp -f "$(shell go env GOROOT)/misc/wasm/wasm_exec.js" ./static/wasm_exec.js
