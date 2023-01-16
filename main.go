package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"path"
	"runtime"
	"time"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	Version           = "0.1.0"
	GitTag            string
	GitBranch         string
	GitBranchState    string
	GitCommit         string
	GitLastCommitTime string
	BinaryName        string
	BuildTime         string

	port string
)

func version() string {
	return fmt.Sprintf("build time: %s\n%s: %s\n%s %s\nBranch: %s\nCommit: %s\n",
		BuildTime,
		path.Base(os.Args[0]), Version,
		runtime.Version(), runtime.GOARCH,
		GitBranch,
		GitCommit)
}

// show prints the version var above
func show() {
	fmt.Println(version())
}

func hello(w http.ResponseWriter, req *http.Request) {
	fmt.Println("http <hello> request")
	fmt.Fprintf(w, "Hello there, the time is %s. The app version is: %s\n", time.Now(), version())
}

func headers(w http.ResponseWriter, req *http.Request) {
	fmt.Println("http <headers> request")
	for name, headers := range req.Header {
		for _, h := range headers {
			fmt.Fprintf(w, "%v: %v\n", name, h)
		}
	}
}

func main() {
	flag.StringVar(&port, "port", ":8080", "http service listen port")
	flag.Parse()
	show()
	fmt.Println("serve http service")
	http.Handle("/metrics", promhttp.Handler())
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/headers", headers)

	http.ListenAndServe(port, nil)
}
