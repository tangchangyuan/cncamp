package main

import (
	"errors"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
)


func main() {
	//单独写回调函数
	http.HandleFunc("/get", getHandler)
	http.HandleFunc("/healthz", healthz)
	// addr：监听的地址
	// handler：回调函数
	err := http.ListenAndServe(":80", nil)
	if err != nil {
		log.Fatal(err)
	}
}

func healthz(writer http.ResponseWriter, request *http.Request) {
	_, err := io.WriteString(writer, "ok")
	if err != nil {
		log.Fatal(err)
	}
}

func getHandler(writer http.ResponseWriter, request *http.Request) {
	defer request.Body.Close()

	header := request.Header
	for s, strings := range header {
		for _, s2 := range strings {
			writer.Header().Set(s,s2)
		}
	}
	fmt.Println(header)
	env := os.Getenv("VERSION")
	goroot := os.Getenv("GOROOT")
	writer.Header().Set("VERSION",env)
	writer.Header().Set("GOROOT",goroot	)

	ipAddr,_ := GetIP(request)
	fmt.Println(ipAddr)


}

// GetIP returns request real ip.
func GetIP(r *http.Request) (string, error) {
	ip := r.Header.Get("X-Real-IP")
	if net.ParseIP(ip) != nil {
		return ip, nil
	}

	ip = r.Header.Get("X-Forward-For")
	for _, i := range strings.Split(ip, ",") {
		if net.ParseIP(i) != nil {
			return i, nil
		}
	}

	ip, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return "", err
	}

	if net.ParseIP(ip) != nil {
		return ip, nil
	}

	return "", errors.New("no valid ip found")
}
