UI.App.addEventListener('launch', function() {
	var screen = new UI.Screen();
	screen.title = navigator.platform;
	screen.view.backgroundColor = 'red';
	
	var rightBarButton = new UI.BarButton();
	rightBarButton.title = 'Present';
	rightBarButton.addEventListener('tap', function() {
		presentScreen(screen);
	});
	
	screen.rightButton = rightBarButton;
	
	var navScreen = new UI.NavigationScreen(screen);
	
	UI.App.mainScreen = navScreen;
});

function presentScreen(parent) {
	var screen = new UI.Screen();
	screen.title = navigator.platform;
	screen.view.backgroundColor = 'white';
	
	var rightBarButton = new UI.BarButton(UI.BarButton.DONE);
	rightBarButton.addEventListener('tap', function() {
		screen.dismissScreen();
	});
	screen.rightButton = rightBarButton;	
	
	var view = new UI.View(0, 0, 320, 40);
	view.backgroundColor = 'magenta';
	view.autoresizingMask = UI.View.FLEXIBLE_WIDTH;
	screen.view.addSubview(view);
	
	var navScreen = new UI.NavigationScreen(screen);
	parent.presentScreen(navScreen);
}