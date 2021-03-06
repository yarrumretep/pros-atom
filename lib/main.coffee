{NewProjectView} = require './views/new-project/new-project-view'
{RegisterProjectView} = require './views/register-project/register-project-view'
{UpgradeProjectView} = require './views/upgrade-project/upgrade-project-view'
{Disposable} = require 'atom'
fs = require 'fs'
cli = require './cli'
{consumeRunInTerminal, consumeDisplayConsole} = require './terminal-utilities'
{provideBuilder} = require './make'
lint = require './lint'
config = require './config'
universalConfig = require './universal-config'
autocomplete = require './autocomplete/autocomplete-clang'

module.exports =
  consumeRunInTerminal: consumeRunInTerminal
  provideBuilder: provideBuilder

  activate: ->
    require('atom-package-deps').install('pros').then () =>
      if config.settings('').override_beautify_provider
        atom.config.set('atom-beautify.c.default_beautifier', 'clang-format')
      lint.activate()
      autocomplete.activate()
      @newProjectViewProvider = NewProjectView.register
      @newProjectPanel = new NewProjectView

      @registerProjectViewProvider = RegisterProjectView.register
      @registerProjectPanel = new RegisterProjectView

      @upgradeProjectViewProvider = UpgradeProjectView.register
      @upgradeProjectPanel = new UpgradeProjectView

      # atom.commands.add 'atom-work  space',
      #   'PROS:Toggle-PROS': => @togglePROS()
      atom.commands.add 'atom-workspace',
        'PROS:New-Project': => @newProject()
      atom.commands.add 'atom-workspace',
        'PROS:Upgrade-Project': => @upgradeProject()
      atom.commands.add 'atom-workspace',
        'PROS:Register-Project': => @registerProject()
      atom.commands.add 'atom-workspace',
        'PROS:Upload-Project': => @uploadProject()

      cli.execute(((c, o) -> console.log o),
        cli.baseCommand().concat ['conduct', 'first-run', '--no-force', '--use-defaults'])

  consumeLinter: lint.consumeLinter

  uploadProject: ->
    if atom.project.getPaths().length > 0
      cli.uploadInTerminal atom.project.getPaths()[0]

  newProject: ->
    @newProjectPanel.toggle()

  registerProject: ->
    @registerProjectPanel.toggle()

  upgradeProject: ->
    @upgradeProjectPanel.toggle()

  consumeToolbar: (getToolBar) ->
    @toolBar = getToolBar('pros')

    @toolBar.addButton {
      icon: 'folder-add',
      callback: 'PROS:New-Project',
      tooltip: 'Create a new PROS Project',
      iconset: 'fi'
    }

    @toolBar.onDidDestroy => @toolBar = null

  autocompleteProvider: ->
    autocomplete.provide()

  consumeStatusBar: ->


  config: universalConfig.filterConfig config.config, 'atom'
