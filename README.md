# PresideCMS Extension: Zabbix Statistics Reporter

This is an extension for PresideCMS that provides configuration and an API for reporting to [Zabbix](http://www.zabbix.com/).

*The extension relies on Zabbix Agent being installed on the server running the preside application*.

## Configuration

The extension provides a system configuration screen that allows you to configure:

* *Sender executable:* Path to the `zabbix_sender`, e.g. `/usr/bin/zabbix_sender`
* *Remote server:* Hostname or IP address of remote Zabbix server that will receive data
* *Remote port:* Port of the remote Zabbix server that will receive data (default is 10051)
* *Zabbix Hostname:* The hostname of the host, as configured in Zabbix, that all data will be recorded against

## API

### Direct sending of data

The extension provides a single API method through the `ZabbixSender` service, `send( data, keyPrefix="presidecms" )`. Example usage:

```
component {
    property name="zabbixSender" inject="zabbixSender";
    property name="syncService"  inject="syncService";

    function sendSyncStatsToZabbix() {
        zabbixSender.send( data={
              syncfailures = syncService.getFailureCount()
            , syncqueued   = syncService.getQueueCount()
            , synctotal    = syncService.getTotalProcessedCount()
        } );
    }
}
```

All sent data keys are prefixed by default with "presidecms". In the example above, the following variables would be sent to Zabbix: `presidecms[syncfailures]`, `presidecms[syncqueued]`, `presidecms[synctotal]`.

### Provided scheduled task

A scheduled task (requires the Taskmanager preside extension) is supplied that announces a `onCollectSystemStats` interception point in order to gather statistics from the application. To provide statistics in this way, listen for the interception point with an interceptor, e.g.

```
component {

    property name="taskManagerService" inject="delayedInjector:taskmanagerService";

    public void function configure() output=false {
        return;
    }

// listeners
    public void function onCollectSystemStats( event, interceptData ) {
        interceptData[ "taskmanager_failure_count" ] = taskManagerService.getFailureCount();
        // etc.
    }

}
```

## Logging

The extension defines a 'zabbixSender' logbox logger that, by default, logs to `(yourapp)/logs/zabbix-sender.log`. Warnings, errors and sending info will be recorded here.

## Installation

Install the extension to your application via either of the methods detailed below (Git submodule / CommandBox) and then enable the extension by opening up the Preside developer console and entering:

    extension enable preside-ext-zabbix
    reload all

### Git Submodule method

From the root of your application, type the following command:

    git submodule add https://github.com/pixl8/preside-ext-zabbix.git application/extensions/preside-ext-zabbix

### CommandBox (box.json) method

From the root of your application, type the following command:

    box install pixl8/preside-ext-zabbix#v1.0.0




