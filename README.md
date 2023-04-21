BDecoder Torrent文件解析类
========

Torrent File Decoder


          var parser:BDecoder = new BDecoder("utf-8", true);
          //data is the torrent's ByteArray
          var item:Item = parser.decodeStream(data);
          var info:TorrentInfo = new TorrentInfo(item);

Online: http://kingnare.github.io/bdecoder/


![img](https://github.com/kingnare/kingnare.github.io/raw/master/A.png)
