package com.kingnare.bittorrent
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;

	public class TorrentInfo
	{
		private var _item:Item;
		/**
		 * 种子服务器
		 */	
		public var announce:String = "";
		/**
		 * 种子服务器列表
		 */	
		public var announceList:Array = [];
		/**
		 * 创建时间
		 */	
		public var createTime:Date = new Date(1970,1,1,0,0,0);
		/**
		 * 创建者
		 */	
		public var createdBy:String = "";
		/**
		 * CODEPAGE
		 */	
		public var codePage:String = "";
		/**
		 * 编码
		 */	
		public var encoding:String = "";
		/**
		 * 注解
		 */	
		public var comment:String = "";
		/**
		 * 注解(UTF-8)
		 */	
		public var commentUTF8:String = "";
		/**
		 * 文件列表
		 */	
		public var fileList:Array = [];
		/**
		 * 文件总大小
		 */	
		public var fileTotalSize:Number = 0;
		/**
		 *  种子名称
		 */		
		public var name:String = "";
		/**
		 * 种子名称(UTF-8)
		 */		
		public var nameUTF8:String = "";
		/**
		 * 分块大小, 每个块的大小，单位字节(整数)
		 */	
		public var pieceLength:Number = 0;
		/**
		 * 每个块的20个字节的SHA1 Hash的值(二进制格式)
		 */	
		public var pieces:ByteArray = new ByteArray();
		/**
		 * 文件块数量
		 */	
		public var pieceCount:Number = 0;
		/**
		 * 特征码
		 */	
		public var hash:String = "";
		/**
		 * 特征码(每8个字符为一组, 共5组)
		 */	
		public var hashWithSpace:String = "";
		/**
		 * 发布者
		 */	
		public var publisher:String = "";
		/**
		 * 发布者(UTF-8)
		 */	
		public var publisherUTF8:String = "";
		/**
		 * 发布者网站
		 */	
		public var publisherUrl:String = "";
		/**
		 * 发布者网站(UTF-8)
		 */	
		public var publisherUrlUTF8:String = "";
		/**
		 * DHT节点
		 */	
		public var notes:Array = [];

		/**
		 * Torrent文件信息 
		 * @param item
		 * 
		 */		
		public function TorrentInfo(item:Item)
		{
			_item = item;
			
			if(item)
				parse(item);
		}
		
		/**
		 * 分析结果
		 * @param item
		 * 
		 */		
		private function parse(item:Item):void
		{
			if(item.type == ItemType.DICT)
			{
				//种子名称
				if(item.value["info"].value["name"])
					name = item.value["info"].value["name"].value.string;
				if(item.value["info"].value["name.utf-8"])
					nameUTF8 = item.value["info"].value["name.utf-8"].value.string;
				//发布者
				if(item.value["info"].value["publisher"])
					publisher = item.value["info"].value["publisher"].value.string;
				if(item.value["info"].value["publisher.utf-8"])
					publisherUTF8 = item.value["info"].value["publisher.utf-8"].value.string;
				//发布者网址
				if(item.value["info"].value["publisher-url"])
					publisherUrl = item.value["info"].value["publisher-url"].value.string;
				if(item.value["info"].value["publisher-url.utf-8"])
					publisherUrlUTF8 = item.value["info"].value["publisher-url.utf-8"].value.string;
				//codepage
				if(item.value["codepage"])
					codePage = item.value["codepage"].value;
				//编码
				if(item.value["encoding"])
					encoding = item.value["encoding"].value.string;
				//注解
				if(item.value["comment"])
					comment = item.value["comment"].value.string;
				if(item.value["comment.utf-8"])
					commentUTF8 = item.value["comment.utf-8"].value.string;
				//创建
				if(item.value["created by"])
					createdBy = item.value["created by"].value.string;
				//DHT节点
				if(item.value["nodes"])
				{
					notes = item.value["nodes"].value;
				}
				//种子服务器
				if(item.value["announce"])
				{
					announce = item.value["announce"].value.string;
				}
				//种子服务器列表
				if(item.value["announce-list"])
				{
					var announces:Array = item.value["announce-list"].value as Array;
					if(announces && announces.length>0)
					{
						for(var i:int=0;i<announces.length;i++)
						{
							announceList.push(announces[i].value[0].value.string);
						}
					}
				}
				//创建日期
				if(item.value["creation date"])
				{
					createTime = new Date(item.value["creation date"].value*1000);
				}
				//分块信息
				if(item.value["info"].value["piece length"])
				{
					pieceLength = parseInt(item.value["info"].value["piece length"].value);
				}
				if(item.value["info"].value["pieces"])
				{
					pieceCount = Math.round(item.value["info"].value["pieces"].value.count/20);
				}
				//Hash Code
				if(item.value["hash"])
				{
					hash = item.value["hash"].value.string.toUpperCase();
					hashWithSpace = hash.substr(0, 8)+" "+hash.substr(8, 8)+" "+hash.substr(16, 8)+" "+hash.substr(24, 8)+" "+hash.substr(32,8);
				}
				//文件列表
				var totalsize:Number = 0;
				var files:Array = [];
				
				//多文件
				if(item.value["info"].value["files"])
				{
					var fileitems:Array = item.value["info"].value["files"].value as Array;
					if(fileitems && fileitems.length>0)
					{
						for(var j:int=0;j<fileitems.length;j++)
						{
							totalsize += Number(fileitems[j].value["length"].value);
							
							var path:String = "";
							if(fileitems[j].value["path"])
							{
								var paths:Array = fileitems[j].value["path"].value as Array;
								if(paths && paths.length>0)
								{
									for(var k:int=0;k<paths.length;k++)
									{
										path += paths[k].value.string + "/";
									}
									
									path = path.substr(0, path.length-1);
								}
							}
							
							var pathUTF8:String = "";
							if(fileitems[j].value["path.utf-8"])
							{
								var pathsUTF8:Array = fileitems[j].value["path.utf-8"].value as Array;
								if(pathsUTF8 && pathsUTF8.length>0)
								{
									for(var k8:int=0;k8<pathsUTF8.length;k8++)
									{
										pathUTF8 += pathsUTF8[k8].value.string + "/";
									}
									
									pathUTF8 = pathUTF8.substr(0, pathUTF8.length-1);
								}
							}
							
							files.push({filepath:path, 
										filepathUTF8:pathUTF8,
										filesize:fileitems[j].value["length"].value});
						}
					}
				}
				//单文件
				else
				{
					totalsize = Number(item.value["info"].value["length"].value);
					var utf8name:String = "";
					var fname:String = "";
					if(item.value["info"].value["name.utf8"])
						utf8name = item.value["info"].value["name.utf8"].value.string;
					if(item.value["info"].value["name"])
						fname = item.value["info"].value["name"].value.string;
					files.push({filepath:fname, filepathUTF8:utf8name, filesize:totalsize});
				}
				
				fileList = files;
				fileTotalSize = totalsize;
				
				
			}
		}
		
		/**
		 * 转换为XML格式
		 * @return 
		 * 
		 */		
		public function toXML():XML
		{
			return transToXML(_item);
		}
		
		/**
		 * 转换为XML格式
		 * @param item
		 * @return 
		 * 
		 */		
		private function transToXML(item:Item):XML
		{
			var re:XML = null;
			
			if(item)
			{
				switch(item.type)
				{
					case ItemType.DICT:
						re = <node label="DICTIONARY"/>;
						for(var key:String in item.value as Dictionary)
						{
							var node:XML = <node label={"KEY = \""+key+"\""}/>;
							if(key != "pieces")
							{
								node.appendChild(transToXML(item.value[key] as Item));
							}
							else
							{
								transToXML(item.value[key] as Item);
								node.appendChild(<node label={"BYTEARRAY  长度:"+(item.value[key] as Item).value.count}/>);
							}
							re.appendChild(node);
						}
						break;
					case ItemType.LIST:
						re = <node label="ARRAY"/>;
						var tmpArr:Array = item.value as Array;
						if(tmpArr)
						{
							for(var j:int=0;j<tmpArr.length;j++)
							{
								re.appendChild(transToXML(tmpArr[j] as Item));
							}
						}
						break;
					case ItemType.STRING:
						return <node label={"STRING = \""+item.value.string+"\"  字节长度:"+item.value.count}/>;
					case ItemType.INT:
						return <node label={"INT = "+item.value}/>;
				}
			}
			
			return re;
		}
	}
}