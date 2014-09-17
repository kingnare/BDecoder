package com.kingnare.bittorrent
{
	import flash.utils.ByteArray;

	/**
	 * BDecoder文件流
	 * @author Kingnare
	 * 
	 */	
	public class BDecoderStream extends ByteArray
	{
		/**
		 * 默认编码 
		 */		
		public var defaultEncoding:String = "utf-8";
		
		public function BDecoderStream()
		{
            
		}
		
		/**
		 * 读取长度为length的字节码
		 * @param length 读取长度
		 * @param isBytes 如果为true, 那么返回长度为length的字节码
		 * @return 以默认编码读取的字符串或字节码
		 * 
		 */		
		public function readNextChar(length:int=1, isBytes:Boolean=false):*
		{
			if(this.bytesAvailable)
			{
				if(this.bytesAvailable<length)
				{
					throw new Error("遇到文件尾");
				}
					
				if(!isBytes)
				{
					return this.readMultiByte(length, defaultEncoding);
				}
				else
				{
					var bytes:ByteArray = new ByteArray();
					this.readBytes(bytes, 0, length);
					return bytes;
				}
			}
			
			return null;
		}
	}
}