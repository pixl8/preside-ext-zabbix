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
 	 * @taskManagerService.inject   taskManagerService
 	 *
 	 */
 	public any function init( required any updateManagerService, required any taskManagerService ) {
 		_setUpdateManagerService( arguments.updateManagerService );
 		_setTaskManagerService( arguments.taskManagerService );

 		return this;
 	}

 // PUBLIC API METHODS
 	public struct function getStats() {
 		var updateManagerService = _getUpdateManagerService();
 		var version              = updateManagerService.getCurrentVersion();
 		var versionIsAtLeast107  = updateManagerService.compareVersions( version, "10.7.0" ) >= 0;
 		var stats                = {
 			"version" = "PresideCMS v" & version
 		};

 		if ( versionIsAtLeast107 ) {
 			stats.append( _getTaskManagerService().getStats() );
 		}

 		return stats;
 	}

 // PRIVATE HELPERS

 // GETTERS AND SETTERS
 	private any function _getUpdateManagerService() {
 		return _updateManagerService;
 	}
 	private void function _setUpdateManagerService( required any updateManagerService ) {
 		_updateManagerService = arguments.updateManagerService;
 	}

 	private any function _getTaskManagerService() {
 		return _taskManagerService;
 	}
 	private void function _setTaskManagerService( required any taskManagerService ) {
 		_taskManagerService = arguments.taskManagerService;
 	}

 }