#!/bin/bash

echo "--------------------------------------------------------------------------------------"
echo "          SOLR STARTUP SCRIPT"
echo "--------------------------------------------------------------------------------------"
# Hostname
HOST=`hostname -s`

# Additional Env Variables
ZOOK=${ZOOK:-"zk-cs:2181"}
CLOUD=${CLOUD:-"yes"}

SOLR_PORT=${SOLR_PORT:-"8983"}
SOLR_HOME=${SOLR_HOME:-"/store/solr"}
SOLR_LOGS_DIR=${SOLR_LOGS_DIR:-"/store/logs"}
JAVA_MEM_OPTS=${JAVA_MEM_OPTS:-"-Xms512m -Xmx512m"}
GC_TUNE=${GC_TUNE:-"-XX:NewRatio=3 -XX:SurvivorRatio=4 -XX:TargetSurvivorRatio=90 \
	-XX:MaxTenuringThreshold=8 -XX:+UseConcMarkSweepGC -XX:ConcGCThreads=4 -XX:ParallelGCThreads=4 \
	-XX:+CMSScavengeBeforeRemark -XX:PretenureSizeThreshold=64m -XX:+UseCMSInitiatingOccupancyOnly \
	-XX:CMSInitiatingOccupancyFraction=50 -XX:CMSMaxAbortablePrecleanTime=6000 -XX:+CMSParallelRemarkEnabled \
	-XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow"}
GC_LOG_OPTS=${GC_LOG_OPTS:-"-Xlog:gc*:file=/store/gc-logs/solr_gc.log:time,uptime:filecount=9,filesize=20000"}
CLOUD_MODE_OPTS=${CLOUD_MODE_OPTS:-"-DzkClientTimeout=15000 -DzkHost=zk-cs:2181"}

# Print Some Info

echo "----------------------------------"
echo "          USER                    "
echo "----------------------------------"
echo "user:             $USER"
echo "----------------------------------"
echo "          ENV                     "
echo "----------------------------------"
echo "PATH:             $PATH"
echo "ZOOK:             $ZOOK"
echo "CLOUD:            $CLOUD"
echo "PORT:             $PORT"
echo "HOST:             $HOST"
echo "-----------------------------------"
echo "          JAVA                     "
echo "-----------------------------------"
java -version

[ -z "$ZOOK" ] && { 
	echo "Can't start Solr. ZOOK missing. Aborting"; 
	exit 1; 
}

# Always start in foreground
cmd="solr -f"

cmd="$cmd -h $HOST.solr-svc.default.svc.cluster.local"

[ "$CLOUD" = "yes" ] && { cmd="$cmd -c"; }

cmd="$cmd -z $ZOOK"

# Verbose docker scripts
cmd="$cmd -verbose"

echo "STARTING SOLR WITH CMD: $cmd"
echo "--------------------------------------------------------------------------------------"
exec $cmd