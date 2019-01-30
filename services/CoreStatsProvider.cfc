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
	 * @configuredFeatures.inject   coldbox:setting:features
	 * @extensionManager.inject     extensionManagerService
	 */
	public any function init(
		  required any    updateManagerService
		, required any    taskManagerService
		, required any    extensionManager
		, required struct configuredFeatures
	) {
		_setUpdateManagerService( arguments.updateManagerService );
		_setTaskManagerService( arguments.taskManagerService );
		_setExtensionManager( arguments.extensionManager );
		_setConfiguredFeatures( StructKeyArray( arguments.configuredFeatures ) );

		return this;
	}

// PUBLIC API METHODS
	public struct function getStats() {
		var updateManagerService = _getUpdateManagerService();
		var version              = updateManagerService.getCurrentVersion();
		var versionIsAtLeast107  = updateManagerService.compareVersions( version, "10.7.0" ) >= 0;
		var versionIsValid       = ListLen( version, "." ) >= 3;
		var stats                = {
			  "version"          = "PresideCMS v" & version
			, "version.major"    = versionIsValid ? Val( ListGetAt( version, 1, "." ) ) : 0
			, "version.minor"    = versionIsValid ? Val( ListGetAt( version, 2, "." ) ) : 0
			, "version.patch"    = versionIsValid ? Val( ListGetAt( version, 3, "." ) ) : 0
			, "enabled.features" = _getEnabledFeatureList()
		};

		stats.append( _getCacheStats() );
		stats.append( _getExtensionDetails() );
		if ( versionIsAtLeast107 ) {
			stats.append( _getTaskManagerService().getStats() );
		}

		return stats;
	}

// PRIVATE HELPERS
	private struct function _getCacheStats() {
		var cachebox   = $getColdbox().getCachebox();
		var cacheNames = cachebox.getCacheNames();
		var allStats   = {};

		for( var cacheName in cacheNames ){
			if ( cachebox.cacheExists( cacheName ) ) {
				var cache      = cachebox.getCache( cacheName );
				var config     = cache.getMemento().configuration;
				var cacheStats = cache.getStats();

				cacheName = LCase( cacheName );

				allStats[ "cache.#cacheName#.objects"    ] = cacheStats.getObjectCount();
				allStats[ "cache.#cacheName#.maxobjects" ] = Val( config.maxObjects ?: 0 );
				allStats[ "cache.#cacheName#.hits"       ] = cacheStats.getHits();
				allStats[ "cache.#cacheName#.misses"     ] = cacheStats.getMisses();
				allStats[ "cache.#cacheName#.evictions"  ] = cacheStats.getEvictionCount();
				allStats[ "cache.#cacheName#.perfratio"  ] = cacheStats.getCachePerformanceRatio();
				allStats[ "cache.#cacheName#.gcs"        ] = cacheStats.getGarbageCollections();
			}
		}

		return allStats;
	}

	private string function _getEnabledFeatureList() {
		var configuredFeatures = _getConfiguredFeatures();
		var enabled = [];

		for( var feature in configuredFeatures ) {
			if ( $isFeatureEnabled( feature ) ) {
				enabled.append( feature );
			}
		}

		return "," & enabled.toList() & ",";
	}

	private struct function _getExtensionDetails() {
		var extensions = _getExtensionManager().listExtensions();
		var simpleList = [];
		var details    = {};

		for( var extension in extensions ) {
			simpleList.append( extension.id );
			details[ "#extension.id#.version" ] = extension.version;
			var isValidVersion = ListLen( extension.version, "." ) >= 3;

			if ( isValidVersion ) {
				details[ "#extension.id#.version.major" ] = ListGetAt( extension.version, 1, "." );
				details[ "#extension.id#.version.minor" ] = ListGetAt( extension.version, 2, "." );
				details[ "#extension.id#.version.patch" ] = ListGetAt( extension.version, 3, "." );
			}
		}
		details[ "installed.extensions" ] = "," & simpleList.toList() & ",";

		return details;
	}


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

	private any function _getExtensionManager() {
		return _extensionManager;
	}
	private void function _setExtensionManager( required any extensionManager ) {
		_extensionManager = arguments.extensionManager;
	}

	private array function _getConfiguredFeatures() {
		return _configuredFeatures;
	}
	private void function _setConfiguredFeatures( required array configuredFeatures ) {
		_configuredFeatures = arguments.configuredFeatures;
	}
}