UI.App.addEventListener('launch', function() {
	var screen = new UI.Screen();
	screen.view.backgroundColor = 'rgb(255, 0, 0)';
	
	UI.App.mainScreen = screen;
});