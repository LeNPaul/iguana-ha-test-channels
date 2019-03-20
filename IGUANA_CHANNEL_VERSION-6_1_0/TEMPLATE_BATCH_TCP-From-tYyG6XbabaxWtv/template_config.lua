{
   "cron": {
      "tab": "0 12 * * *",
      "runnow": "runderful"
   },
   "retry": {
      "pause": 10,
      "times": 3
   },
   "source":{
      "path": "source_path",
      "files":  [
		  "*"
	]
    },
    "destination":{
      "path":"destination_path",
      "files":[
      "*"
      ]
     },
   "transport": {  <-- use Iguana Api parameter and options
      "protocol": "sftp",
      "parameters": {
      	"server": "hostname",
      	"username": "id",
      	"password":"password",
      	"timeout": 60
      }
   }
}