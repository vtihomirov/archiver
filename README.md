# archiver
A simple archiving script:
  > Archives the contents of a folder if the modified file time stamp is older than 30 day

#### Usage:

```
  ./archiver.rb /path/to/scan /path/to/archive
```

#### Use it with cron job

##### 1st day of the month

```
* * 1 * * /path/to/archiver.rb /src/path /archive/path
```

https://en.wikipedia.org/wiki/Cron
