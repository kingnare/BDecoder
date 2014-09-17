BDecoder
========

Torrent File Decoder


          var parser:BDecoder = new BDecoder("utf-8", true);
          //data is the torrent's ByteArray
          var item:Item = parser.decodeStream(data);
	  var info:TorrentInfo = new TorrentInfo(item);
