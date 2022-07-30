using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Sensor;
using Toybox.Communications;
using Toybox.WatchUi as Ui;
using Toybox.System as sys;
using Toybox.Time;
using Toybox.Time.Gregorian;


class LokiRunsApp extends Application.AppBase {

var view= null;
var START=-1000000;
var dlon= START, dlat= START, dspeed= START, dhr= START, hr, speed= START, cadence, heading, altitude, accelX, accelY, accelZ, magX, magY, magZ, oxygenSat, power, pressure, temperature, location, longitude=START, latitude=START;
var duration= new Time.Duration(1000);
var lastrequest= null;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	sensorInitialize();
  		initializePositionListener();
  
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	view = new LokiRunsView();  	
        return [ view, new LokiRunsDelegate() ];
    }
    
    function initializePositionListener() {
    Position.enableLocationEvents( Position.LOCATION_CONTINUOUS, method( :onPosition ) );
}

function onPosition( info ) {
	if(view != null && info.position != null) {
		location = info.position.toDegrees();
		view.updateLocation(location[0], location[1]);
		makeRequest();
	}	
}

function sensorInitialize() {
    Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
    Sensor.enableSensorEvents(method(:onSensor));
}

function onSensor(sensorInfo) {
	hr= sensorInfo.heartRate;
  	if(view != null && hr!= null) {
        speed= sensorInfo.speed;
        altitude= sensorInfo.altitude;
        heading= sensorInfo.heading;
        cadence= sensorInfo.cadence;
        accelX= sensorInfo.accel[0];
        accelY= sensorInfo.accel[1];
        accelZ= sensorInfo.accel[2];
        magX= sensorInfo.mag[0];
        magY= sensorInfo.mag[1];
        magZ= sensorInfo.mag[2];
      /*
        // Breaks devices without OxygenSat sensor
        try {
            oxygenSat= sensorInfo.oxygenSaturation;
        }
        catch(exception) {
            oxygenSat= 100;
        }*/
        power= sensorInfo.power;
        pressure= sensorInfo.pressure;
        temperature= sensorInfo.temperature;
        if(temperature== null) {
            temperature= 0;
        }
        if(power== null) {
            power= 0;
        }
        if(pressure== null) {
            pressure= 0;
        }
	 	view.updateHR(hr);
        view.updateSpeed(""+speed);
	 	makeRequest();
	 }
}


   function makeRequest() {
    var now=  Time.now();
    
    if(lastrequest!= null && now.compare(lastrequest)<1) {    	
    	return;
    }
    
    lastrequest= now;
   	var user= sys.getDeviceSettings().uniqueIdentifier; 	
    var url = Ui.loadResource(Rez.Strings.CLOUDRUN_ENDPOINT);
	var lons=0, lats=0;
    var tdhr= hr, tdlat= 0, tdlon= 0, tdspeed= speed;

    if(location!= null) {
		lons= location[1];
		lats= location[0];
        if(dlat!= START) {
            tdlat= dlat-location[0];
        }
        if(dlon!= START) {
            tdlon=dlon- location[1];
        }
	}
    if(dhr!= START) {
        tdhr= hr- dhr;
    }
    if(dspeed!= START) {
        tdspeed= speed- dspeed;
    }
    if(dlat!= START) {
        tdlat= location[0]- dlat;
    }
    if(dlon!= START) {
        tdlon= location[1]- dlon;
    }
  
    var logline = "{\"heartrate\":"+hr+", \"deltaHeartrate\":"+tdhr+", \"deltaSpeed\":"+tdspeed+", \"deltaLongitude\":"+tdlon+", \"deltaLatitude\":"+tdlat+", \"temperature\":"+temperature+", \"pressure\":"+pressure+", \"power\":"+power+", \"magX\":"+magX+", \"magY\":"+magY+", \"magZ\":"+magZ+", \"accelX\":"+accelX+", \"accelY\":"+accelY+", \"accelZ\":"+accelZ+", \"speed\":"+speed+", \"cadence\":"+cadence+", \"altitude\":"+altitude+", \"heading\":"+heading+", \"longitude\":"+lons+", \"latitude\":"+lats+", \"user\":\""+user+"\"}";
    if(speed!= null) {
        dspeed= speed;
    }
    if(location!= null) {
        dlat= location[0];
        dlon= location[1];
    }
    if(hr!= null) {
        dhr= hr;
    }

    var labels= {                                              
        "app" => "lokiruns"
    };
   
    var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var m= today.month as Lang.Number;
    if(m< 10) {
        m="0"+m;
    }
    var d= today.day as Lang.Number;
    if(d< 10) {
        d="0"+d;
    }
    var h= today.hour as Lang.Number;
    if(h< 10) {
        h="0"+h;
    }
    var mi= today.min as Lang.Number;
    if(mi< 10) {
        mi="0"+mi;
    }
    var s= today.sec as Lang.Number;
    if(s< 10) {
        s="0"+s;
    }

    var dateString = Lang.format(
    "$1$-$2$-$3$T$4$:$5$:$6$Z",
        [
            today.year,
            m,
            d ,
            h,
            mi,
            s
        ]
    );
    var line = {
        "message" => logline,
        "level" => "info",
        "context" => labels ,
        "timestamp"=> dateString
    };
    var logs = {
        "logs" => [line]
    };
    var key=Ui.loadResource(Rez.Strings.API_KEY);

    var options = {  
        :method => Communications.HTTP_REQUEST_METHOD_POST,      
        :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON, "x-api-key" => key },                                                         
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_URL_ENCODED
    };
    var responseCallback = method(:onReceive);      
    Communications.makeWebRequest(url, logs, options, method(:onReceive));
  }

function onReceive(responseCode, data) {
       if (responseCode == 200) {
           System.println("Request Successful");                 
       }
       else {
           System.println("Response: " + responseCode);   
           System.println(data);        
       }
   }
}
