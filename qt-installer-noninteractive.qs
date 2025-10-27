function Controller() {
    installer.autoAcceptLicenses();
    installer.installationFinished.connect(function() {
        console.log("Installation finished!");
    });
}

Controller.prototype.WelcomePageCallback = function() {
    // Skip welcome page
}

Controller.prototype.CredentialsPageCallback = function() {
    // Skip credentials page for open source
}

Controller.prototype.IntroductionPageCallback = function() {
    // Skip introduction page
}

Controller.prototype.TargetDirectoryPageCallback = function() {
    gui.currentPageWidget().TargetDirectoryLineEdit.setText("/opt/Qt");
}

Controller.prototype.ComponentSelectionPageCallback = function() {
    var widget = gui.currentPageWidget();
    widget.deselectAll();

    // Select Qt 5.15.2 components for Android
    widget.selectComponent("qt.qt5.5152.android_armv7");
    widget.selectComponent("qt.qt5.5152.android_arm64_v8a");
    widget.selectComponent("qt.qt5.5152.android_x86");
    widget.selectComponent("qt.qt5.5152.android_x86_64");
    widget.selectComponent("qt.qt5.5152.qtcharts");
    widget.selectComponent("qt.qt5.5152.qtquicktimeline");
    widget.selectComponent("qt.qt5.5152.qtwebengine");
    widget.selectComponent("qt.qt5.5152.qtsvg");
    widget.selectComponent("qt.qt5.5152.qtmultimedia");
    widget.selectComponent("qt.qt5.5152.qttools");

    // Select Developer and Designer Tools
    widget.selectComponent("qt.tools.qtcreator");
    widget.selectComponent("qt.tools.android");
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
}

Controller.prototype.ReadyForInstallationPageCallback = function() {
    gui.currentPageWidget().CommitButton.click();
}

Controller.prototype.FinishedPageCallback = function() {
    var widget = gui.currentPageWidget();
    widget.LaunchQtCreatorCheckBoxForm.launchQtCreatorCheckBox.setChecked(false);
    gui.clickButton(buttons.FinishButton);
}