function Application() {
	
};

Application.prototype.run = function() {
	var mainScreen = new MainScreen();
	
	UI.App.mainScreen = new UI.NavigationScreen(mainScreen.screen);
};

UI.App.addEventListener('launch', function() {
	(new Application()).run();	
});

function MainScreen() {
	this.screen = new UI.Screen();
	
	this.data = [
		{
			id: 1,
			name: 'John Smith'
		},
		{
			id: 2,
			name: 'Donna Noble'
		},
		{
			id: 3,
			name: 'Martha Jones'
		},
		{
			id: 4,
			name: 'Rose Tyler'
		},
		{
			id: 5,
			name: 'Amelia Pond'
		},
		{
			id: 6,
			name: 'Rory Williams'
		},
		{
			id: 7,
			name: 'Clara Oswin Oswald'
		},
		{
			id: 8,
			name: 'River Song'
		}
	];
	
	this.tableView = new UI.TableView(UI.TableView.PLAIN_STYLE);
	this.tableView.width = this.screen.view.width;
	this.tableView.height = this.screen.view.height;
	this.tableView.autoresizingMask = UI.View.FLEXIBLE_HEIGHT | UI.View.FLEXIBLE_WIDTH;
	
	var self = this;
	
	this.tableView.addSection(function(section) {
		for(var i = 0; i < self.data.length; i++) {
			var cell = section.addCell(function(cell, indexPath) {
				cell.textLabel.text = self.data[indexPath.row].name;
			});
			cell.reuseIdentifier = "Cell";
			cell.style = UI.TableViewCell.DEFAULT_STYLE;
		}
	});
	
	this.screen.view.addSubview(this.tableView);
};