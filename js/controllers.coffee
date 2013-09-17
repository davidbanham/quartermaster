app = angular.module('CoffeeModule')

app.controller "FieldMarshalCtrl", ($scope, $store, $http, $location, FieldMarshal) ->

  $store.bind($scope,"fieldmarshalInfo")
  $scope.fieldmarshalInfo.port = 4001 if !$scope.fieldmarshalInfo.port? or $scope.fieldmarshalInfo.port is ''
  $location.path 'settings' if !$scope.fieldmarshalInfo.host? or $scope.fieldmarshalInfo.host is ''

  $http.defaults.headers.common.authorization = "Basic #{btoa("quartermaster:" + $scope.fieldmarshalInfo.pass)}"

  mungeSlavesToProcs = (slaves) ->
    $scope.allProcs = []
    for name, slave of slaves
      for pid, proc of slave.processes
        proc.slave = name
        proc.port = proc.opts.env.PORT
        proc.commit = proc.opts.commit
        $scope.allProcs.push proc

  $scope.getSlaves = ->
    FieldMarshal.get
      action: 'slaves'
      host: "#{$scope.fieldmarshalInfo.host}:#{$scope.fieldmarshalInfo.port}"
    , (data, status, headers, config) ->
      mungeSlavesToProcs(data)
      $scope.slavesStr = JSON.stringify(data, null, "  ")
      for name, slave of data
        continue if name[0] is '$'
        slave.numProcs = Object.keys(slave.processes).length
      $scope.slaves = data

  intervals = []

  intervals.push setInterval $scope.getSlaves, 3000 #tonight we're going to poll it like it's nineteen ninety nine
  $scope.getSlaves()

  $scope.$on '$destroy', (e) ->
    clearInterval interval for interval in intervals

  $scope.sort =
    column: 'port'
    descending: 'true'

  $scope.changeSorting = (column) ->
    sort = $scope.sort
    if sort.column is column
      sort.descending = !sort.descending
    else
      sort.column = column
      sort.descending = false

  $scope.stop = (slave, pid) ->
    FieldMarshal.save {
      action: 'stop'
      host: "#{$scope.fieldmarshalInfo.host}:#{$scope.fieldmarshalInfo.port}"
      slave: slave
      ids: [pid]
    }
