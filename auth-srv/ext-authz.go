package main
import "os"
import "fmt"
import "bufio"
import "bytes"
import "encoding/json"

type AuthzInfoFmt struct {
  Account string
  Type string
  Name string
  Service string
  IP string
  Labels []string
  Actions []string
}

func main() {
  var buffer bytes.Buffer
  scanner := bufio.NewScanner(os.Stdin)
  for scanner.Scan() {
    buffer.WriteString(scanner.Text())
  }

  authzInfo := []byte(buffer.String())
  info := AuthzInfoFmt{}
  err :=json.Unmarshal(authzInfo, &info)

  if err != nil {
    panic(err)
  }

  fmt.Println(info.Account)
  fmt.Println(info.Type)
  fmt.Println(info.Name)
  fmt.Println(info.Service)
  fmt.Println(info.IP)
  fmt.Println(info.Labels)
  fmt.Println(info.Actions)
  os.Exit(0)
}

