using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.WatchUi as Ui;
using Toybox.System as System;

class MWDataFieldView extends WatchUi.DataField {

    hidden const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    hidden var distance = 0;
    hidden var elapsedTime = 0;
    hidden var hr = 0;

    hidden var lastLapTime = 0;
    hidden var lastLapDistance = 0;


    function initialize() {
        DataField.initialize();
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {

        // レイアウトの設定
        View.setLayout(Rez.Layouts.MainLayout(dc));
        // ヘッダテキストの設定
        View.findDrawableById("drawable_distance_label").setText(Rez.Strings.str_distance);
        View.findDrawableById("drawable_pace_label").setText(Rez.Strings.str_pace);
        View.findDrawableById("drawable_hr_label").setText(Rez.Strings.str_hr);

        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
        elapsedTime = info.timerTime ? info.timerTime : 0;
        hr = info.currentHeartRate != null ? info.currentHeartRate : 0;
    }

    // 1秒起きに実行され表示を更新するメソッド
    function onUpdate(dc) {

        View.findDrawableById("Background").setColor(getBackgroundColor());

        // ForeGround Colorで矩形を埋める
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.fillRectangle(0, 0, width, height);

        // Total距離の表示(distanceStr)
        var distanceStr;
        if (distance > 0) {
            var distKm = distance / 1000;
            if (distKm < 100) {
                distanceStr = distKm.format("%.2f");
            } else {
                distanceStr = distKm.format("%.1f");
            }
        } else {
            distanceStr = "0.00";
        }
        var valueDistance = View.findDrawableById("drawable_distance_val");
        valueDistance.setText(distanceStr);

        // kmのラップ表示
        var lapTime = (elapsedTime - lastLapTime) / 1000;
        var lapDist = distance - lastLapDistance;
        var lapPace = 0;
        if(lapDist > 0){
             lapPace = lapTime / lapDist;
        }
        var lapPaceStr = displayPace(lapPace);
        var valuePace = View.findDrawableById("drawable_pace_val");
        valuePace.setText(lapPaceStr);


        // 心拍数表示
        var valueHr = View.findDrawableById("drawable_hr_val");
        valueHr.setText(hr.toString());

        // Power(Stryd)
        // RE
        // 血糖値

        // 時刻
        var clockTime = System.getClockTime();
        var clockStr = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
        var valueClock = View.findDrawableById("drawable_clock_val");
        valueClock.setText(clockStr);

        // 経過時間
        var durationStr = "0:00";
        if (elapsedTime != null && elapsedTime > 0) {
            var hours = null;
            var minutes = elapsedTime / 1000 / 60;
            var seconds = elapsedTime / 1000 % 60;

            if (minutes >= 60) {
                hours = minutes / 60;
                minutes = minutes % 60;
            }

            if (hours == null) {
                durationStr = minutes.format("%d") + ":" + seconds.format("%02d");
            } else {
                durationStr = hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
            }
        }
        var valueDuration = View.findDrawableById("drawable_duration_val");
        valueDuration.setText(durationStr);

        // バッテリ残
        var battery = System.getSystemStats().battery;
        var valueBattery = View.findDrawableById("drawable_battery_val");
        valueBattery.setText(battery.toNumber().toString());

        // 線を引く
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, height/2, width, height/2);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }



    // ラップ時に呼び出されるメソッド
    // ラップペースの計算に使う
    function onTimerLap() {
        lastLapTime = elapsedTime;
        lastLapDistance = distance;
    }

    // 引数で取得した秒数を mm:ss 形式に変換する
    function displayPace(pace_seconds) {
        if (pace_seconds == null || pace_seconds == 0) {
            return "0:00";
        }
        var seconds = pace_seconds.toNumber();
        var minutes = seconds / 60;
        seconds %= 60;
        return Lang.format("$1$:$2$", [minutes, seconds.format("%02d")]);
    }


}
