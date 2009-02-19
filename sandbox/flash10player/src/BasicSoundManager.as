package {	import flash.media.SoundTransform;    	import flash.events.Event;    import flash.events.IOErrorEvent;    import flash.events.ProgressEvent;    import flash.events.TimerEvent;    import flash.media.Sound;    import flash.media.SoundChannel;    import flash.net.URLRequest;    import flash.utils.Timer;        public class BasicSoundManager implements ISoundManager    {        private var _observers : Vector.<ISoundManagerObserver>;        private var _soundUrl : String;        private var _sound : Sound;        private var _soundChannel : SoundChannel;        private var _timer : Timer;        private var _loop : Boolean;        private var _lastPosition : Number;        private var _isPlaying : Boolean;        private var _isLoaded:Boolean;        private var _durationEstimate:Number;        private static const TIMER_DELAY : int = 10;        public function BasicSoundManager(soundUrl : String, durationEstimate:Number) : void        {            _observers = new Vector.<ISoundManagerObserver>;        	            _lastPosition = 0;            _isPlaying = false;            _isLoaded = false;            _durationEstimate = durationEstimate;            _soundUrl = soundUrl;            _sound = new Sound(new URLRequest(_soundUrl));            _sound.addEventListener(Event.COMPLETE, onSoundLoadComplete);            _sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundIoError);            _sound.addEventListener(ProgressEvent.PROGRESS, onSoundLoadProgress);                        _timer = new Timer(TIMER_DELAY);            _timer.addEventListener(TimerEvent.TIMER, onTimerEvent);            _timer.start();        }                public function get duration():Number        {        	if (_sound)        		return _sound.length;        	else        		return 0;        }                public function get playState():Boolean        {            return _isPlaying;        }        public function addSoundManagerObserver(observer : ISoundManagerObserver) : void        {            _observers.push(observer);        }        public function set loop(on : Boolean) : void        {            _loop = on;        }        public function get loop() : Boolean        {            return _loop;        }                public function jump(procent:Number):void        {        	trace("jump", procent);        	        	if (procent > 1.0 || procent < 0.0) return;        	        	if (_sound)        	{				if (_isLoaded)				{		        	if (_isPlaying)		        		stop(false);	        			            	_lastPosition = _sound.length * procent;				}	            else if (_durationEstimate * procent < _sound.length)	            {		        	if (_isPlaying)		        		stop(false);		           	_lastPosition = _durationEstimate * procent;	            }	            	            if (!_isPlaying)	            	play();        	}        }                public function forward():void        {        	if (! _soundChannel)        		return;        	        	if (_isLoaded)        		jump(_soundChannel.position / _sound.length + 0.01);        	else        		jump(_soundChannel.position / _durationEstimate + 0.01);		}        public function rewind():void        {        	if (! _soundChannel)        		return;        	        	if (_isLoaded)        		jump(_soundChannel.position / _sound.length - 0.01);        	else        		jump(_soundChannel.position / _durationEstimate - 0.01);		}        public function play() : void        {            if (_isPlaying || !_sound) return;                        if (_soundChannel)            {                _soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayComplete);                _soundChannel = null;            }            _soundChannel = _sound.play(_lastPosition);            _soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundPlayComplete);            _isPlaying = true;            for each (var observer: ISoundManagerObserver in _observers)            	observer.onSoundManagerPlay(this);        }        public function get playing() : Boolean        {            return _isPlaying;        }        public function pause() : void        {            if (!_isPlaying || !_sound) return;            _lastPosition = _soundChannel.position;            _soundChannel.stop();            _isPlaying = false;                        for each (var observer: ISoundManagerObserver in _observers)            	observer.onSoundManagerPause(this);        }        public function stop(notify:Boolean=true) : void        {        	if (!_sound) return;        	            _lastPosition = 0;            _soundChannel.stop();            _isPlaying = false;                        if (notify)            {	            for each (var observer: ISoundManagerObserver in _observers)	            {	                observer.onSoundManagerPlaying(this, 0, 0);	                observer.onSoundManagerStop(this);	            }            }        }        private function onSoundLoadProgress(event : ProgressEvent) : void         {            var progress : Number = _sound.bytesLoaded / _sound.bytesTotal;                        for each (var observer: ISoundManagerObserver in _observers)            	observer.onSoundManagerLoading(this, progress);        }        private function onSoundLoadComplete(event : Event) : void        {            _isLoaded = true;                        for each (var observer: ISoundManagerObserver in _observers)            	observer.onSoundManagerLoaded(this);        }        private function onTimerEvent(e : TimerEvent) : void        {            if (_sound && _soundChannel && _isPlaying)            {            	var position:Number;            	                if (_isLoaded)                	position = _soundChannel.position / _sound.length;                else                	position = _soundChannel.position / _durationEstimate;                	                for each (var observer: ISoundManagerObserver in _observers)	            	observer.onSoundManagerPlaying(this, position, _soundChannel.position);            }        }        private function onSoundPlayComplete(e : Event) : void        {            _isPlaying = false;            _lastPosition = 0;            if (_loop)                play();        	else            {                for each (var observer: ISoundManagerObserver in _observers)                {                    observer.onSoundManagerPlaying(this, 0, 0);                    observer.onSoundManagerStop(this);                }            }        }        private function onSoundIoError(event : Event) : void        {            for each (var observer: ISoundManagerObserver in _observers)        		observer.onSoundManagerError(this, "Failed loading sound:\n" + _soundUrl);        }    }}