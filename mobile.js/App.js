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
	
	this.tableView = new UI.TableView(UI.TableView.PLAIN_STYLE);
	this.tableView.width = this.screen.view.width;
	this.tableView.height = this.screen.view.height;
	this.tableView.autoresizingMask = UI.View.FLEXIBLE_HEIGHT | UI.View.FLEXIBLE_WIDTH;
	
/*
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
*/
	
	UI.App.networkActivityIndicatorVisible = true;
	
	var self = this;
	
	var request = new XMLHttpRequest();
	request.open("GET", "https://api.github.com/users/grantjbutler/repos");
	request.responseType = 'json';
	request.onload = function() {
		self.tableView.insertSection(function(section) {
			for(var i = 0; i < request.response.length; i++) {
				var cell = section.addCell(function(cell, indexPath) {
					cell.textLabel.text = request.response[indexPath.row].full_name;
				});
				cell.reuseIdentifier = "Cell";
				cell.style = UI.TableViewCell.DEFAULT_STYLE;
			}
		}, 0);
		
		UI.App.networkActivityIndicatorVisible = false;
	};
	request.send();
	
	this.screen.view.addSubview(this.tableView);
};