class GoogleAnalyticsDataAdapter
  constructor: (@chartQuery, @json) ->

  @_axisNames: []

  _getXAxisName: ->
    dimensions = @chartQuery.dimensions
    _.find(gaDimensionsList, (dimension) ->
      dimension.key is dimensions)?.value or ""

  _getYAxisesNames: ->
    metricsList = @chartQuery.metrics.split ","
    axisesCount = metricsList.length
    yAxisesNames = (_.find(gaMetricsList, (metric) -> metric.key is metricsList[i])?.value or "" for i in [0..axisesCount])

  getCategories: ->
    _.map @json.result.rows, (el) ->
      el[0]

  getAxisNames: ->
    @_axisNames =
      x: @_getXAxisName()
      y: @_getYAxisesNames()

  getSeries: ->
    # example series [{data: [119, 56], name: "abc"}, {data: [100, 23], name: "def"}]
    series = []
    axisNames = @_axisNames
    rows = @json.result.rows
    axisesCount = rows[0].length - 1

    series = ({
    data: _.map rows, (row) -> (parseInt element for element, index in row when index is (axisIndex + 1))
    name: axisNames.y[axisIndex]
    } for axisIndex in [0..axisesCount])

    if @chartQuery.mergeMetrics
      seriesMerger = new App.DataMisc.GASeriesMerger series[0].data, series[1].data
      seriesMerger.getSeries()
    else
      series

_.extend App.DataAdapters, {
  GoogleAnalytics: GoogleAnalyticsDataAdapter
}