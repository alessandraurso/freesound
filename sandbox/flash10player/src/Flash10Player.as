package  {    import flash.ui.Keyboard;        import ui.IPlayerControlsObserver;    import ui.ISoundDisplayObserver;    import ui.PlayerControls;    import ui.SoundDisplay;    import flash.display.Sprite;    import flash.events.KeyboardEvent;    	[Embed(source='../media/VeraMono.ttf', fontName='VeraMono', fontWeight='normal', unicodeRange='u+0000-u+00ff' )]	    [SWF( backgroundColor='0xffffff', width='900', height='201', frameRate='60')]    public class Flash10Player extends Sprite implements ISoundManagerObserver, ISoundDisplayObserver, IPlayerControlsObserver    {        private var _baseUrl : String, _waveformUrl : String, _spectralUrl : String, _soundUrl : String;        private var _durationEstimate : Number;        private var _soundDisplay : SoundDisplay;        private var _soundManager : BasicSoundManager;        private var _loop:Boolean;                public function Flash10Player()        {            if (loaderInfo.parameters["baseUrl"])	            _baseUrl = loaderInfo.parameters["baseUrl"];            else            	_baseUrl = "../media/";            	            if (loaderInfo.parameters["waveformUrl"])	            _waveformUrl = loaderInfo.parameters["waveformUrl"];            else            	_waveformUrl = "waveform.png";            if (loaderInfo.parameters["spectralUrl"])	            _spectralUrl = loaderInfo.parameters["spectralUrl"];            else            	_spectralUrl = "spectral.jpg";                        if (loaderInfo.parameters["soundUrl"])            	_soundUrl = loaderInfo.parameters["soundUrl"];            else	            _soundUrl = "preview.mp3";	                        if (loaderInfo.parameters["duration"])            	_durationEstimate = loaderInfo.parameters["duration"];            else	            _durationEstimate = 3457.95;	            	        _loop = false;            _soundDisplay = new SoundDisplay(900, 201, _baseUrl + _waveformUrl, _baseUrl + _spectralUrl, _durationEstimate);            _soundDisplay.addSoundDisplayObserver(this);            _soundDisplay.addPlayerControlsObserver(this);            addChild(_soundDisplay);            stage.focus = this;			            addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);         }        private function onKeyPressed(e : KeyboardEvent) : void        {            switch (e.keyCode)            {            	case Keyboard.SPACE:	            {	                createSoundManager();							                if (_soundManager)	                {	                    if (_soundManager.playing)		                    	_soundManager.pause();		                    else		                    	_soundManager.play();	                }	                break;	            }	            case Keyboard.RIGHT:	            {	            	trace("right");	                if (_soundManager)	                	_soundManager.forward();					break;	            }	            case Keyboard.LEFT:	            {	            	trace("left");	                if (_soundManager)	                	_soundManager.rewind();					break;	            }            }        }        private function createSoundManager() : void        {            if (!_soundManager)            {                _soundManager = new BasicSoundManager(_baseUrl + _soundUrl, _durationEstimate);				_soundManager.loop = _loop;				_soundManager.addSoundManagerObserver(this);			}        }        public function onSoundDisplayClick(soundDisplay : SoundDisplay, procent : Number) : void        {            createSoundManager();            _soundManager.jump(procent);   			stage.focus = this;        }        /************ PlayerControl callbacks************************************************/        public function playClicked(playerControls : PlayerControls) : void         {            createSoundManager();            _soundManager.play();        };        public function pauseClicked(playerControls : PlayerControls) : void        {            if (_soundManager)            	_soundManager.pause();        };        public function stopClicked(playerControls : PlayerControls) : void        {            if (_soundManager)		    	_soundManager.stop();        };        public function spectralClicked(playerControls : PlayerControls) : void        {            _soundDisplay.setSpectralBackground();            _soundDisplay.updateMeasureDisplay();        };        public function waveformClicked(playerControls : PlayerControls) : void        {            _soundDisplay.setWaveformBackground();            _soundDisplay.updateMeasureDisplay();        };        public function loopOnClicked(playerControls : PlayerControls) : void        {        	_loop = true;            if (_soundManager)	    		_soundManager.loop = true;        };        public function loopOffClicked(playerControls : PlayerControls) : void        {        	_loop = false;            if (_soundManager)				_soundManager.loop = false;        };        public function measureOnClicked(playerControls : PlayerControls) : void        {            _soundDisplay.measureReadout(true);            _soundDisplay.updateMeasureDisplay();        };        public function measureOffClicked(playerControls : PlayerControls) : void        {            _soundDisplay.measureReadout(false);            _soundDisplay.updateMeasureDisplay();        };        /************ SoundManager callbacks************************************************/        public function onSoundManagerLoading( soundManager : ISoundManager, progress : Number ) : void        {            //_soundDisplay.setSoundDuration(_soundManager.duration);            _soundDisplay.setLoading(progress);        };        public function onSoundManagerError( soundManager : ISoundManager, errorMsg : String ) : void        {            _soundDisplay.displayErrorMessage(errorMsg);        };        public function onSoundManagerLoaded(soundManager : ISoundManager) : void        {            _soundDisplay.setSoundDuration(_soundManager.duration);            _soundDisplay.setLoading(1.0);        };        public function onSoundManagerPlay(soundManager : ISoundManager) : void        {            _soundDisplay.setPlayButtonState(true);        };        public function onSoundManagerPlaying( soundManager : ISoundManager, position : Number, time : Number ) : void        {            _soundDisplay.setPlaying(position, time);        };        public function onSoundManagerPause(soundManager : ISoundManager) : void        {            _soundDisplay.setPlayButtonState(false);        };        public function onSoundManagerStop(soundManager : ISoundManager) : void        {            _soundDisplay.setPlayButtonState(false);        };    }}