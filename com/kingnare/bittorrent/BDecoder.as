package com.kingnare.bittorrent
{
	import com.adobe.crypto.SHA1;
	
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	/**
	 * Bencode解码器, 主要针对torrent文件
	 * @author Kingnare
	 * 
	 */	
	public class BDecoder
	{
		private static const DICT:String = "d";
		private static const LIST:String = "l";
		private static const END:String = "e";
		private static const INT:String = "i";
		
		public var defaultEncoding:String = "utf-8";
        private var originBytes:ByteArray;
		private var source:BDecoderStream;
		private var infoBeginPos:int = 0;
		private var infoEndPos:int = 0;
		private var autoChkCharSet:Boolean = true;
		
		/**
		 * 构造方法
		 * @param charSet 默认编码
		 * @param autoCheckCharSet 自动检测编码
		 * 
		 */		
		public function BDecoder(charSet:String="utf-8", autoCheckCharSet:Boolean=true)
		{
			source = new BDecoderStream();
            //originBytes = new ByteArray();
			autoChkCharSet = autoCheckCharSet;
			defaultEncoding = charSet;
			source.defaultEncoding = charSet;
            
		}
		
		/**
		 * 对torrent文件流解码
		 * @param bytes 文件字节码
		 * @return 
		 * @see Item
		 * 
		 */		
		public function decodeStream(bytes:ByteArray):Item
		{
			var item:Item = null;
			
			if(bytes && bytes.bytesAvailable)
			{
                bytes.position = 0;
                source.clear();
				bytes.readBytes(source, 0, bytes.length);
                
				var firstChr:String = source.readNextChar();
				if(firstChr != "d")
				{
					throw new Error("错误的Torrent文件,起始字符不是d");
				}
				
				source.position = 0;
				item = decode();
				
				if(infoBeginPos>0 && infoEndPos>0 && infoBeginPos < infoEndPos)
				{
					source.position = infoBeginPos;
					var hashSourceBytes:ByteArray = new ByteArray();
					var len:uint = infoEndPos-infoBeginPos;
					source.readBytes(hashSourceBytes, 0, len);
					hashSourceBytes.position = 0;
					item.value["hash"] = new Item(ItemType.STRING, {count:len, string:SHA1.hashBytes(hashSourceBytes)});
				}
			}
			
			return item;
		}
		
		/**
		 * 对字串解码 
		 * @return 
		 * @see Item
		 * 
		 */				
		private function decode():Item
		{
			var tmp:String = source.readNextChar();
			var item:Item = new Item();
			
			switch(tmp)
			{
				case DICT :
					item.type = ItemType.DICT;
					item.value = readDict();
					break;
				case LIST :
					item.type = ItemType.LIST;
					item.value = readList();
					break;
				case END :
				case "-1" :
					return null;
				case INT :
					item.type = ItemType.INT;
					item.value = readInt();
					break;
				case "0":
				case "1":
				case "2":
				case "3":
				case "4":
				case "5":
				case "6":
				case "7":
				case "8":
				case "9":
					item.type = ItemType.STRING;
					source.position = source.position - 1;
					item.value = readString();
					break;
				default:
					throw new Error("字段起始符不是关键字");
			}
			
			return item;
		}
		
		
		/**
		 * 读取字典 格式: d字典e
		 * 内部元素由key-value键值对组成, key是字符串, value可以是字符串, 整数, 列表, 字典等
		 * @return 
		 * @see flash.utils.Dictionary
		 * 
		 */		
		private function readDict():Dictionary
		{
			var re:Dictionary = new Dictionary();
			var needReload:Boolean = false;
			do
			{
				var headStr:String = source.readNextChar();
				
				//如果当前原始串是表模式的结束字符。则停止提取
				if (headStr == "e")
					break;
				
				source.position = source.position-1;
				//取得字典中数据项的名称
				var key:String = readString().string;
				//得到INFO块的起始位置
				if(key == "info")
				{
					infoBeginPos = source.position;
				}
				
				if(key.indexOf(".utf-8")!=-1)
				{
					source.defaultEncoding = "utf-8";
				}
				else
				{
					source.defaultEncoding = defaultEncoding;
				}
				//提取当前字典模式中所包含的其他编码模式的内容
				var value:Item = decode();
				
				//得到INFO块的结束位置
				if(key == "info")
				{
					infoEndPos = source.position;
				}
				
				re[key] = value;
				
				if(key == "encoding" && autoChkCharSet)
				{
					defaultEncoding = value.value.string.toString();
					
                    if(source.defaultEncoding != defaultEncoding)
                    {
                        source.defaultEncoding = defaultEncoding;
                    }
				}
			}
			while (true);
			
			return re;
		}
		
		/**
		 * 读取列表 格式: l列表e
		 * 列表中含有字符串, 整数, 列表, 字典等
		 * @return 
		 * @see Array
		 * 
		 */		
		private function readList():Array
		{
			var re:Array = [];
			
			do
			{
				var headStr:String = source.readNextChar();
				
				//如果当前原始串是表模式的结束字符。则停止提取
				if (headStr == "e")
					break;
				
				source.position = source.position-1;
				//提取表模式中包含的其他模式的所代表的内容
				var tmp:Item = decode();	
				re.push(tmp);
				
			}
			while (true);
			
			return re;
		}
		
		/**
		 * 读取字符串 格式: 字符串长度:字符串
		 * @return 
		 * @see Object
		 * 
		 */		
		private function readString():Object
		{
			var tmpStr:String = "";
			var tmpByte:String = source.readNextChar();
			
			while (tmpByte != ":" && tmpByte != "")
			{
				tmpStr += tmpByte;
				tmpByte = source.readNextChar();
			}
			
			var count:uint = uint(tmpStr);
			
			var re:String = source.readNextChar(count);
			
			return {count:count, string:re};
		}
		
		/**
		 * 读取整型 格式: i数字e
		 * 
		 * @return
		 * 
		 */		
		private function readInt():Number
		{
			var tmpStr:String = "";
			var tmpByte:String = source.readNextChar();
			
			while (tmpByte != "e" && tmpByte != "")
			{
				tmpStr += tmpByte;
				tmpByte = source.readNextChar();
			}
			
			return Number(tmpStr);
		}
		
		/*private function fixCodingString(item:Item):void
		{
			switch(item.type)
			{
				case ItemType.DICT:
					var dict:Dictionary = item.value as Dictionary;
					for(var key:String in dict)
					{
						fixCodingString(dict[key]);
					}
					break;
				case ItemType.LIST:
					var array:Array = item.value as Array;
					for(var i:int=0;i<array.length;i++)
					{
						fixCodingString(array[i]);
					}
					break;
				case ItemType.STRING:
					
					break;
				case ItemType.INT:
					break;
				default:
			}
		}*/
		
	}
	
}