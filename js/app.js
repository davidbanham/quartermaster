angular.module('CoffeeModule', ['localStorage', 'fieldMarshalService', 'ngResource'])
.config(['$routeProvider', function($routeProvider) {
  $routeProvider.
    when('/settings', {templateUrl: 'views/settings.html', controller: 'FieldMarshalCtrl'}).
    when('/processes', {templateUrl: 'views/processes.html', controller: 'FieldMarshalCtrl'}).
    otherwise({templateUrl: 'views/processes.html', controller: 'FieldMarshalCtrl'})
}])
