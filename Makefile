run-example-server:
	swift run --package-path ./Examples ServerRun

curl-request:
	curl http://127.0.0.1:8080/file_lsit -d '{"expect": $(EXPECT)}' -X POST