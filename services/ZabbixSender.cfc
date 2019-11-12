/**
 * Provides logic for sending data to Zabbix
 *
 * @singleton
 * @presideservice
 *
 */
component {

// CONSTRUCTOR
	/**
	 * @logger.inject logbox:logger:zabbixsender
	 *
	 */
	public any function init( required any logger ) {
		_setLogger( arguments.logger );

		return this;
	}

// PUBLIC API METHODS
	public boolean function send( required struct data, any logger=_getLogger(), keyPrefix="presidecms" ) {
		var tmpFile         = _writeDataToTempFile( data, keyPrefix );
		var configuration   = $getPresideCategorySettings( "zabbix" );
		var executionReport = "";
		var errorReport     = "";
		var canError        = logger.canError();
		var canWarn         = logger.canWarn();
		var canInfo         = logger.canInfo();

		if ( configuration.isEmpty() ) {
			if ( canWarn ) {
				logger.warn( "The Zabbix integration is not configured." );
			}
			return false;
		}

		if ( canInfo ) {
			logger.info( "Sending [#NumberFormat( StructCount( data ) )#] data points to Zabbix..." );
		}

		try {

			execute name          = configuration.sender_executable
			        arguments     = '-z "#configuration.remote_server#" -p #configuration.remote_port# -s "#configuration.application_hostname#" -i "#tmpFile#"'
			        timeout       = 10
			        variable      = "executionReport"
			        errorVariable = "errorReport";

		} catch ( any e ) {
			if ( canError ) {
				logger.error( e.message );
				return false;
			}
		}

		if ( !ReFindNoCase( "processed: [1-9]", executionReport ) ) {
			errorReport = executionReport;
		}

		if ( Len( Trim( errorReport ) ) ) {
			if ( canError ) {
				logger.error( errorReport );
				return false;
			}
		} else if ( Len( Trim( executionReport ) ) ) {
			if ( canInfo ) {
				logger.info( executionReport );
				return true;
			}
		}

		return false;
	}

// PRIVATE HELPERS
	private string function _writeDataToTempFile( required struct data, required string keyPrefix ) {
		var tmpFile = getTempFile( getTempDirectory(), "zabbixstats" );

		for( var key in arguments.data ) {
			FileAppend( tmpFile, "- #keyPrefix#[#key#] #arguments.data[ key ]#" & Chr( 10 ) );
		}

		return tmpFile;
	}

// GETTERS AND SETTERS
	private any function _getLogger() {
		return _logger;
	}
	private void function _setLogger( required any logger ) {
		_logger = arguments.logger;
	}

}