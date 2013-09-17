angular.module('CoffeeModule', ['localStorage', 'fieldMarshalService', 'ngResource'])
.config(['$routeProvider', function($routeProvider) {
  $routeProvider.
    when('/settings', {templateUrl: 'views/settings.html', controller: 'FieldMarshalCtrl'}).
    when('/processes', {templateUrl: 'views/processes.html', controller: 'FieldMarshalCtrl'}).
    when('/slaves', {templateUrl: 'views/slaves.html', controller: 'FieldMarshalCtrl'}).
    when('/manifest', {templateUrl: 'views/manifest.html', controller: 'FieldMarshalCtrl'}).
    otherwise({templateUrl: 'views/slaves.html', controller: 'FieldMarshalCtrl'})
}])
