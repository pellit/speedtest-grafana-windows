package main

import (
	"fmt"

	"github.com/showwin/speedtest-go/speedtest"
)

/*medData := [][]string{
	{"Latencia", "Download", "Upload"},
	{"Smith", "Newyork", "Java"},
	{"William", "Paris", "Golang"},
	{"Rose", "London", "PHP"},
}*/

func main() {
	//csvFile, err := os.Create("speedtest.csv")

	/*if err != nil {
		log.Fatalf("Fallo la creacion del archivo: %s", err)
	}*/

	user, _ := speedtest.FetchUserInfo()

	serverList, _ := speedtest.FetchServerList(user)
	targets, _ := serverList.FindServer([]int{})

	for _, s := range targets {
		s.PingTest()
		s.DownloadTest(false)
		s.UploadTest(false)

		fmt.Printf("%s, %f, %f\n", s.Latency, s.DLSpeed, s.ULSpeed)
		//fmt.Println("ms:", string(int64(s.Latency/time.Millisecond))) // ms: 100
		//csvwriter := csv.NewWriter(csvFile)
		//csvwriter.Write(s.Latency)
		//csvwriter.Flush()
		//csvFile.Close()
	}
}
