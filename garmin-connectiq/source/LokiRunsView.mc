using Toybox.WatchUi;

class LokiRunsView extends WatchUi.View {
    var hr= null;
    var speed= null;
    var lon = null;
    var lat = null;
 
    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        hr= findDrawableById("hr");
        hr.setText("---");
        lon= findDrawableById("lon");
		lon.setText("---");
		lat= findDrawableById("lat");
		lat.setText("---");	
        speed= findDrawableById("speed");
        speed.setText("---");
    }

	function updateHR(text) {
		if(hr != null && text != null) {
			hr.setText(text+" bpm");
			WatchUi.requestUpdate();
		}
	}

    function updateSpeed(text) {
		if(speed != null && text != null) {
			speed.setText(text+" m/s");
			WatchUi.requestUpdate();
		}
	}
	
	function updateLocation(lonText, latText) {
		if(lonText != null && latText != null && lon != null && lat != null) {
			lon.setText(lonText+"");
			lat.setText(latText+"");
			WatchUi.requestUpdate();
		}
	}
	
    function onShow() {
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
    }

    function onHide() {
    }
}
