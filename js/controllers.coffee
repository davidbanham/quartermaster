app = angular.module('CoffeeModule')

app.controller "FieldMarshalCtrl", ($scope, $store, $http, $location, FieldMarshal) ->

  $store.bind($scope,"fieldmarshalInfo")

  $scope.fieldmarshalInfo ?= {}
  $scope.fieldmarshalInfo = {} if $scope.fieldmarshalInfo is ""

  fieldmarshalInfo = $scope.fieldmarshalInfo

  $scope.newMarshal =
    port: 4001

  fieldmarshalInfo.marshals ?= {}
  fieldmarshalInfo.selected ?= ''

  selected = fieldmarshalInfo.selected
  $scope.currentMarshal = currentMarshal = fieldmarshalInfo.marshals[selected] or {}

  $location.path 'settings' if !selected?

  $http.defaults.headers.common.authorization = "Basic #{btoa("quartermaster:" + currentMarshal.pass)}"

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
      host: "#{currentMarshal.host}:#{currentMarshal.port}"
    , (data, status, headers, config) ->
      mungeSlavesToProcs(data)
      $scope.slavesStr = JSON.stringify(data, null, "  ")
      for name, slave of data
        continue if name[0] is '$'
        slave.numProcs = Object.keys(slave.processes).length
      $scope.slaves = data

  getManifest = ->
    FieldMarshal.get
      action: 'manifest'
      host: "#{currentMarshal.host}:#{currentMarshal.port}"
    , (manifest) ->
      for name, data of manifest
        continue if !$scope.allProcs?
        continue if name[0] is '$'
        running = 0
        for proc in $scope.allProcs
          running++ if proc.repo is name and proc.opts.commit is data.opts.commit
        data.running = running
      $scope.manifest = manifest

  $scope.getRawManifest = ->
    FieldMarshal.get
      action: 'manifest'
      host: "#{currentMarshal.host}:#{currentMarshal.port}"
    , (manifest) ->
      $scope.rawManifest = JSON.stringify manifest, null, '  '

  intervals = []

  intervals.push setInterval getManifest, 3000 #tonight we're going to poll it like it's nineteen ninety nine
  getManifest()

  intervals.push setInterval $scope.getSlaves, 3000 #tonight we're going to poll it like it's nineteen ninety nine
  $scope.getSlaves()

  $scope.$on '$destroy', (e) ->
    clearInterval interval for interval in intervals

  $scope.conditionalStyle = (instances, running) ->
    return "instancesBelow" if instances > running
    return "instancesAbove" if instances < running
    return ""

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
      host: "#{currentMarshal.host}:#{currentMarshal.port}"
      slave: slave
      ids: [pid]
    }

  $scope.addFieldMarshal = (newMarshal) ->
    $scope.fieldmarshalInfo.marshals[newMarshal.name] = newMarshal
    $scope.fieldmarshalInfo.marshalNames = []
    $scope.fieldmarshalInfo.marshalNames.push(name) for name, _ of $scope.fieldmarshalInfo.marshals

