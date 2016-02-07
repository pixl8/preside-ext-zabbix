/**
 * Provides logic for retreiving core statistics about the application for reporting
 * to Zabbix.
 *
 * @singleton
 * @presideservice
 *
 */
 component {

 // CONSTRUCTOR
 	/**
 	 * @updateManagerService.inject updateManagerService
 	 *
 	 */
 	public any function init( required any updateManagerService ) {
 		_setUpdateManagerService( arguments.updateManagerService );
 		return this;
 	}

 // PUBLIC API METHODS
 	public struct function getStats() {
 		return {
 			"version" = _getUpdateManagerService().getCurrentVersion()
 		};
 	}

 // PRIVATE HELPERS

 // GETTERS AND SETTERS
 	private any function _getUpdateManagerService() {
 		return _updateManagerService;
 	}
 	private void function _setUpdateManagerService( required any updateManagerService ) {
 		_updateManagerService = arguments.updateManagerService;
 	}

 }