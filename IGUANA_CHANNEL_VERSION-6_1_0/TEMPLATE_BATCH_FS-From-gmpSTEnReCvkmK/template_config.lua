{
   "cron": {
      "tab": "0 12 * * *",
      "runnow": "runderful"
   },
   "retry": {
      "pause": 10,
      "times": 3
   },
   "transport": {
      "protocol":""  <-- support ftp,ftps,sftp
   },
   "source":{
      "path": "source_path",
      "files":  [  <-- support mutli file pattern
		  "",
		  ...,
		  ""
	]
    },
    "destination":{
      "path": "destination_path,
      "files":  [  <-- support mutli file pattern
		  "",
		  ...,
		  ""
      ]
     }
   }
}