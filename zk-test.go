package main

import (
	"bytes"
	"flag"
	"fmt"
	"strings"
	"time"

	"github.com/samuel/go-zookeeper/zk"
)

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func connect(serverCSV string) *zk.Conn {
	servers := strings.Split(serverCSV, ",")
	conn, _, err := zk.Connect(servers, time.Second)
	must(err)
	return conn
}

func main() {
	var serverCSV, namespace, actionCSV string
	flag.StringVar(&serverCSV, "servers", "127.0.0.1:2181", "comma separated list of servers")
	flag.StringVar(&namespace, "namespace", "test", "key setting namespace")
	flag.StringVar(&actionCSV, "actions", "notExists,create,isCreated,set,isSet,delete,notExists", "actions to execute")
	flag.Parse()

	conn := connect(serverCSV)
	defer conn.Close()

	flags := int32(0)
	acl := zk.WorldACL(zk.PermAll)

	key := "/" + namespace
	create_bytes := []byte(namespace + "create")
	set_bytes := []byte(namespace + "set")
	for _, action := range strings.Split(actionCSV, ",") {
		switch action {
		case "create":
			path, err := conn.Create(key, create_bytes, flags, acl)
			must(err)
			fmt.Printf("created key %s with value %q\n", path, create_bytes)

		case "isCreated":
			value, _, err := conn.Get(key)
			must(err)
			if !bytes.Equal(value, create_bytes) {
				must(fmt.Errorf("key %s has value %q not %q", key, value, create_bytes))
			}
			fmt.Printf("asserted key %s has value %q\n", key, value)

		case "set":
			_, stat, err := conn.Get(key)
			must(err)
			_, err = conn.Set(key, set_bytes, stat.Version)
			must(err)
			fmt.Printf("set key %s to value %q\n", key, set_bytes)

		case "isSet":
			value, _, err := conn.Get(key)
			must(err)
			if !bytes.Equal(value, set_bytes) {
				must(fmt.Errorf("key %s has value %q not %q", key, value, set_bytes))
			}
			fmt.Printf("asserted key %s has value %q\n", key, value)

		case "delete":
			err := conn.Delete(key, -1)
			must(err)
			fmt.Printf("deleted key %s\n", key)

		case "notExists":
			exists, _, err := conn.Exists(key)
			must(err)
			if exists {
				must(fmt.Errorf("key %s exists", key))
			}
			fmt.Printf("key %s does not exist\n", key)
		}
	}

}
