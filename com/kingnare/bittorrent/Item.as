package com.kingnare.bittorrent
{
	/**
	 * BDecode数据项
	 * @author Kingnare
	 * 
	 */	
	public class Item
	{
		/**
		 * 类型
		 * @see ItemType
		 */		
		private var _type:String;
		/**
		 * 数值
		 */		
		private var _value:Object;

		/**
		 * 数值
		 * @return 
		 * 
		 */		
		public function get value():Object
		{
			return _value;
		}

		public function set value(value:Object):void
		{
			_value = value;
		}

		/**
		 * 类型
		 * @return 
		 * @see ItemType
		 */		
		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}
		
		/**
		 * 构造方法
		 * @param K 键
		 * @param V 值
		 * 
		 */		
		public function Item(K:String="", V:Object=null)
		{
			if(K != "" && V != null)
			{
				_type = K;
				_value = V;
			}
		}
		
		/**
		 * 数值字符串
		 * @return 
		 * 
		 */			
		public function toString():String
		{
			return _value.toString();
		}

	}
}