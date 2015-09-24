React = require 'react/addons'
OnboardingActions = require './onboarding-actions'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup
PageRouterStore = require './page-router-store'

WelcomePage = require './welcome-page'
AccountChoosePage = require './account-choose-page'
AccountSettingsPage = require './account-settings-page'
InitialPreferencesPage = require './initial-preferences-page'
InitialPackagesPage = require './initial-packages-page'

class PageRouter extends React.Component
  @displayName: 'PageRouter'
  @containerRequired: false

  constructor: (@props) ->
    @state = @_getStateFromStore()
    window.OnboardingActions = OnboardingActions

  _getStateFromStore: =>
    page: PageRouterStore.page()
    pageData: PageRouterStore.pageData()

  componentDidMount: =>
    @unsubscribe = PageRouterStore.listen(@_onStateChanged, @)
    {width, height} = React.findDOMNode(@refs.activePage).getBoundingClientRect()
    atom.center()
    atom.setSizeAnimated(width, height, 0)
    atom.show()

  componentDidUpdate: =>
    setTimeout(@_resizePage, 10)

  _resizePage: =>
    {width, height} = React.findDOMNode(@refs.activePage).getBoundingClientRect()
    atom.setSizeAnimated(width, height)

  _onStateChanged: => @setState(@_getStateFromStore())

  componentWillUnmount: => @unsubscribe?()

  render: =>
    <div className="page-frame">
      {@_renderDragRegion()}
      <ReactCSSTransitionGroup
        transitionName="page"
        leaveTimeout={150}
        enterTimeout={150}>
        {@_renderCurrentPage()}
        {@_renderCurrentPageGradient()}
      </ReactCSSTransitionGroup>
      <div className="page-background" style={background: "#f6f7f8"}/>
    </div>

  _renderCurrentPageGradient: =>
    gradient = @state.pageData?.provider?.color
    if gradient
      background = "linear-gradient(to top, #f6f7f8, #{gradient})"
    else
      background = "linear-gradient(to top, #f6f7f8 0%,  rgba(255,255,255,0) 100%),
                    linear-gradient(to right, #e1e58f 0%, #a8d29e 50%, #8bc9c9 100%)"

    <div className="page-gradient" key={"#{@state.page}-gradient"} style={background: background}/>

  _renderCurrentPage: =>
    Component = {
      "welcome": WelcomePage
      "account-choose": AccountChoosePage
      "account-settings": AccountSettingsPage
      "initial-preferences": InitialPreferencesPage
      "initial-packages": InitialPackagesPage
    }[@state.page]

    <div key={@state.page} className="page-container">
      <Component pageData={@state.pageData} ref="activePage" onResize={@_resizePage}/>
    </div>

  _renderDragRegion: ->
    styles =
      top:0
      left:40
      right:0
      height: 20
      zIndex:100
      position: 'absolute'
      "WebkitAppRegion": "drag"
    <div className="dragRegion" style={styles}></div>

module.exports = PageRouter