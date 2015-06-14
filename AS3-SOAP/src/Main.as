package
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.LoadEvent;
	import mx.rpc.soap.SOAPHeader;
	import mx.rpc.soap.WebService;
	
	public class Main extends Sprite
	{
		private var _this:Sprite;
		private var _inp_txt:TextField;
		private var _result_txt:TextField;
		private var _btn_send:SimpleButton;
		
		private var _webservice:WebService;
		private var _serviceOperation:AbstractOperation;
		
		public function Main()
		{
			_this = this;
			initUI();
			initEvent();
		}
		/**
		 * Function initUI
		 * - Use for create user interface 
		 */
		private function initUI():void {
			//crate container for all display object
			var _container:Sprite = new Sprite();
			
			//create input textfield
			_inp_txt = new TextField();
			_inp_txt.type = TextFieldType.INPUT;
			_inp_txt.border = true;
			_inp_txt.width = 150;
			_inp_txt.height = 15;
			_container.addChild(_inp_txt);
			
			//create button 
			_btn_send = new SimpleButton();
			var myButtonSprite:Sprite = new Sprite();
			myButtonSprite.graphics.lineStyle(1, 0x555555);
			myButtonSprite.graphics.beginFill(0xff0000,1);
			myButtonSprite.graphics.drawRect(0,0,40,15);
			myButtonSprite.graphics.endFill();
			var myButtonText:TextField = new TextField();
			myButtonText.text = "CALL";
			myButtonSprite.addChild(myButtonText);
			_btn_send.overState = _btn_send.downState = _btn_send.upState = _btn_send.hitTestState = myButtonSprite;
			_btn_send.x = 160;
			_container.addChild(_btn_send);
			
			//create result textfield
			_result_txt = new TextField();
			_result_txt.type =TextFieldType.DYNAMIC;
			_result_txt.background = true;
			_result_txt.x = 0;
			_result_txt.y = 20;
			_result_txt.width =200;
			_result_txt.multiline = true;
			_result_txt.backgroundColor = 0xcccccc;
			_container.addChild(_result_txt);
			
			_this.addChild(_container);
			//set centerå
			_container.x = (stage.stageWidth-_container.width) / 2;
			_container.y = (stage.stageHeight-_container.height) / 2;
		}
		
		/**
		 * Function initEvent
		 * - Add all event listener 
		 */
		private function initEvent():void{
			//Add Mouse CLICK event to _btn_send
			_btn_send.addEventListener(MouseEvent.CLICK,onClickCall);
		}
		
		/**
		 * Function onClickCall
		 * - Mouse click event callback function for "_btn_send"
		 * @param MouseEvent evt
		 */
		private function onClickCall(evt:MouseEvent):void {
			//your web service url
			var _urlWebService:String = "http://mysoap.local/v1";
			
			//create new WebService instance 
			_webservice = new WebService();
			
			//load WSDL from web service url
			_webservice.loadWSDL(_urlWebService+"/wsdl");
			
			//Add soap header block
			//For this sample, need "Authentiction" header block for every request
			//create new QName instance  
			var qname:QName = new QName(_urlWebService,"Authentication");
			//create object data ( username & key )
			var objAuth:Object = new Object();
			objAuth.username = "demo";
			objAuth.key = "demo";
			
			//create new SOAPHeader from QName & object date
			var authHeader:SOAPHeader = new SOAPHeader(qname,objAuth);
			//add soap header to webserice instance
			_webservice.addHeader(authHeader);
			
			//Add load WSDL completed event listener 
			_webservice.addEventListener(LoadEvent.LOAD, onLoadWSDL_Complete_AndSayHello);
		}
		
		/**
		 * Function onLoadWSDL_Complete_AndSayHello
		 * - Load WSDL completed event listener 
		 * @param LoadEvent e
		 */
		private function onLoadWSDL_Complete_AndSayHello(e:LoadEvent):void{
			//Get "SayHello" operation from soap service
			_serviceOperation = _webservice.getOperation("SayHello");
			
			//Add FaultEvent fail to "SayHello" operation
			_serviceOperation.addEventListener(FaultEvent.FAULT, DisplayError);
			//Add ResultEvent result to "SayHello" operation
			_serviceOperation.addEventListener(ResultEvent.RESULT, DisplayResult);
			
			//Add argument to "SayHello" Operation , for this sample use text value from _inp_txt
			_serviceOperation.arguments = [_inp_txt.text];
			
			//send requst
			_serviceOperation.send();
			return;
		}
		
		/**
		 * Functin DisplayError
		 * - Display eror when request soap web service fail
		 * @param FaultEvent e
		 */
		private function DisplayError(e:FaultEvent):void {
			_serviceOperation.removeEventListener(FaultEvent.FAULT, DisplayError);
			_result_txt.text = e.fault.toString()
		}
		
		/**
		 * Function DisplayResult
		 * - Display result message
		 * @param ResultEvent e
		 */
		private function DisplayResult(e:ResultEvent):void {
			_serviceOperation.addEventListener(ResultEvent.RESULT, DisplayResult);
			_result_txt.text = e.result.message;
		}
	}
}