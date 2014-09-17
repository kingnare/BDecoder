package com.kingnare.bittorrent
{
	/**
	 * BDecode数据项类型<br/><br/>
	 * 
	 * ItemType.DICT = "dict"<br/>
	 * ItemType.LIST = "list"<br/>
	 * ItemType.STRING = "string"<br/>
	 * ItemType.INT = "int"<br/>
	 * 
	 * @author Kingnare
	 * 
	 */	
	public class ItemType
	{
		/**
		 * 字典
		 */		
		public static const DICT:String = "dict";
		/**
		 * 列表
		 */
		public static const LIST:String = "list";
		/**
		 * 字符串
		 */
		public static const STRING:String = "string";
		/**
		 * 整数
		 */
		public static const INT:String = "int";
	}
}