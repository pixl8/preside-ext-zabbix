/**
 * Provide a scheduled task for sending regular notifications to Zabbix. Other
 * extensions and applications can listen in to the 'onCollectSystemStats' event
 * and add reporting statistics that will then find there way into Zabbix.
 *
 * This feature relies on the taskmanager extension being installed (and will
 * simply not run by itself unless it is).
 */
component {

	property name="zabbixSender" inject="zabbixSender";

	/**
	 * Gathers statistics from the system and sends them to Zabbix
	 *
	 * @displayName Send statistics to Zabbix
	 * @schedule    0 *\/1 * * * *
	 * @priority    10
	 * @timeout     10
	 *
	 */
	private boolean function sendStatsToZabbix( event, rc, prc, logger ) {
		var loggerAvailable = !IsNull( logger );
		var canWarn         = loggerAvailable && logger.canWarn();
		var statistics      = {};

		announceInterception( "onCollectSystemStats", statistics );

		if ( statistics.count() ) {
			return zabbixSender.send( statistics, logger ?: NullValue() );
		} else if ( canWarn ) {
			logger.warn( "No statistics supplied to send to Zabbix" );
		}

		return false;
	}
}