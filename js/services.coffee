angular.module('fieldMarshalService', ['ngResource'])
.factory 'FieldMarshal', ($resource) ->
  return $resource 'http://:host/:action', {action: '@action', host: '@host'}
