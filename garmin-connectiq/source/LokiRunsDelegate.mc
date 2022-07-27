using Toybox.WatchUi;

class LokiRunsDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new LokiRunsMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}