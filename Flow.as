package  
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.text.*;
	import flash.net.*
	import flash.system.*;
	import flash.utils.*;

	public class Flow extends MovieClip 
	{
		public var sURL: String = "https://game.aq.com/game/";
		public var versionURL: String = sURL + "gameversion.asp";

		public var mcLoader: MovieClip;
		public var coreGame: MovieClip;
		public var sFile: Object;
		public var sTitle: Object;
		public var sBG: String;

		public var loader: URLLoader;
		public var titleDomain: ApplicationDomain = new ApplicationDomain();
		public var titleClass: Class;

		public function Flow() 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");

			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onDataComplete);
			loader.load(new URLRequest(versionURL));
		}

		public function onDataComplete(event: Event): void
        {
			var version: URLVariables = new URLVariables(event.target.data);
			trace(version);
            if (version.status == "success") {
                sFile = version.sFile;
                sTitle = version.sTitle;
                sBG = version.sBG;
                loadTitle();
				loadGame();
            } else {
				trace(version.strReason);
				mcLoader.strLoad.text = "Error!";
			}
        }

		public function loadTitle(): void
        {
            var loader: Loader = new Loader();
			var request: URLRequest = new URLRequest(sURL + "gamefiles/title/" + sBG);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTitleComplete);
			loader.load(request, new LoaderContext(false, ApplicationDomain.currentDomain));
        }

		public function onTitleComplete(event: Event): void
        {
            trace("Title Loaded");
			if (!event.target.applicationDomain.hasDefinition("TitleScreen")) return;
			this.titleClass = event.target.applicationDomain.getDefinition("TitleScreen") as Class;
        }

		public function loadGame(): void 
		{
			var loader: Loader = new Loader();
			var loaderContext: LoaderContext = new LoaderContext(true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(new URLRequest(sURL + "gamefiles/" + sFile));
		}

		public function onComplete(event: Event): void 
		{
			coreGame = stage.addChildAt(event.currentTarget.content, 0);
			coreGame.params["sLang"] = "en";
			coreGame.params.sURL = sURL;
			coreGame.params.sTitle = "Rekt Artix";
			coreGame.params.isWeb = false;
			coreGame.params.doSignup = false;
			coreGame.params.sBG = sBG;
			coreGame.params.loginURL = sURL + "cf-userlogin.asp";
			coreGame.params.titleDomain = this.titleDomain;
			
			for (var param: Object in root.loaderInfo.parameters)
				coreGame.params[param] = root.loaderInfo.parameters[param];

			mcLoader.visible = false;
		}

		public function onProgress(event: ProgressEvent): void
        {
            var percent:* = event.currentTarget.bytesLoaded / event.currentTarget.bytesTotal * 100;
			mcLoader.mcBar.mcProgress.scaleX = percent;
            mcLoader.strLoad.text = "Loading " + percent + "%";
			mcLoader.strStatus.text = event;
        }

		public function onError(event: IOErrorEvent): void
        {
            trace("Preloader IOError: " + event);
            Loader(event.target.loader).removeEventListener(IOErrorEvent.IO_ERROR, onError);
            mcLoader.strLoad.text = "Error!";
			mcLoader.strStatus.text = event;
        }
	}
}
