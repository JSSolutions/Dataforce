Template.SourcePicker.onRendered ->
  analytics.track 'Opened Source Picker'

Template.SourcePicker.onCreated ->
  @showConnectorEntityPicker = new ReactiveVar false
  @entityPickerConnectorName = new ReactiveVar false
  @curveMetadata = {}

  @setEntityPickerVisibility = (visibility) => @showConnectorEntityPicker.set visibility

  @setConnectorEntity = (connectorName, entity) =>
    @setEntityPickerVisibility(false)
    Session.set connectorName, {entity: entity, enabled: true}

  @showEntityPickerFor = (connectorName) =>
    Session.set('searchQuery', '')
    @entityPickerConnectorName.set connectorName
    @setEntityPickerVisibility true

  @clearSearch = -> Session.set('searchQuery', '')
  @clearSearch()

  @autorun =>
    data = Template.currentData()


Template.SourcePicker.helpers
  showConnectorEntityPicker: -> Template.instance().showConnectorEntityPicker.get()
  connectorName: -> Template.instance().entityPickerConnectorName.get()


Template.SourcePicker.events
  'click .cancel-button': (event, tmpl) ->
    tmpl.data.instance.hide()
    tmpl.clearSearch()

  'click .save-button': (event, tmpl) ->
    tmpl.clearSearch()
    tmpl.data.instance.hide()

  'change.radiocheck [name="metricRadio"]': (event, tmpl) ->
    target = tmpl.$(event.target)
    metricsList = target.closest('.metrics-list')

    fieldName = tmpl.$('input:radio[name=metricRadio]:checked').val()

    axis =
      fieldName: fieldName
      connectorId: metricsList.attr('data-connector')
      entityName: metricsList.attr('data-entity')

    curveId = tmpl.get 'newCurveId'
    axisType = tmpl.data.context

    if not tmpl.curveMetadata.source
      _.extend tmpl.curveMetadata, {
#        source: axis.connectorId
        metadata:
          entityName: axis.entityName
      }

    _.extend tmpl.curveMetadata.metadata, if axisType is 'x' then {metric: axis.fieldName} else {dimension: axis.fieldName}

    Curves.update {_id: curveId}, {
      $set:
#        source: tmpl.curveMetadata.source
        metadata: tmpl.curveMetadata.metadata
    }
