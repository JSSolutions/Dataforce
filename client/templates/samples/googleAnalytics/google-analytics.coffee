Template.googleAnalytics.helpers
  GAaccounts: ->
    Session.get "GAaccounts"

  metricsList: ->
    gaMetricsList

  dimensionsList: ->
    gaDimensionsList

  UAProfileData: ->
    Session.get "UAProfileData"

  addMoreYAxis: ->
    Session.get("addMoreYAxis") or false

  stringify: (obj) ->
    JSON.stringify obj

  selected: (event, suggestion, datasetName) ->
    console.log event, suggestion, datasetName

Template.googleAnalytics.events
  'click #getUAlist': ->
    Meteor.call "GA.getAccounts", (err, result) ->
      Session.set "GAaccounts", result

  'click #chart-type-selector': (e, t) ->
    selectedChartType = t.$(e.target).val()
    Template.instance().chartType.set selectedChartType

  'click #more-axis-checkbox': (e, t) ->
    addSecondAxis = t.$(e.target).prop "checked"
    Session.set "addMoreYAxis", addSecondAxis

  'click #getData': (e, t) ->
    firstMetric = t.$("#metrics-selector").val()
    secondMetric = if (secondMetric = t.$("#second-metrics-selector").val())? then "," + secondMetric else ""
    profileId = t.$("#profile-selector").val()
    dimensions = t.$("#dimensions-selector").val()
    fromDate = t.$("#gaDatepicker input").eq(0).val
    endDate = t.$("#gaDatepicker input").eq(1).val()

    chartQuery =
      profileId: profileId
      metrics: firstMetric + secondMetric
      dimensions: dimensions
      from: fromDate
      to: endDate

    console.log chartQuery

    Meteor.call "GA.getUAProfileData", chartQuery, (err, result) ->
      UAProfileData = _.map result.result, (el) ->
        el[1] = parseInt el[1]
        el[2] = parseInt el[2] if el[2]
        el
      t.rawData.set UAProfileData
      t.axisNames.set
        x: _.find(gaDimensionsList, (el) -> el.key is chartQuery.dimensions).value
        y: _.find(gaMetricsList, (el) -> el.key is firstMetric).value
        y2: _.find(gaMetricsList, (el) -> el.key is secondMetric)?.value
