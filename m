From: "H . J . Lu" <hjl@lucon.org>
Subject: Re: Proposed changes for init file in nfs-utils
Date: Sun, 7 Apr 2002 13:55:05 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020407135505.A6580@lucon.org>
References: <20020406205304.C2076@ee.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from rwcrmhc53.attbi.com ([204.127.198.39])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uJh1-0000JT-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 13:55:19 -0700
To: Sean O'Connell <sean@ee.duke.edu>
In-Reply-To: <20020406205304.C2076@ee.duke.edu>; from sean@ee.duke.edu on Sat, Apr 06, 2002 at 08:53:06PM -0500
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Sat, Apr 06, 2002 at 08:53:06PM -0500, Sean O'Connell wrote:
> Hi-
> 
> I have opened a bugzilla request with the redhat regarding applying some of
> the recommendations from the nfs how-to performance section (chapter 5) and
> also adds a configuration file that lives in /etc/sysconfig and is read in
> by the startup script /etc/init.d/nfs. This was based on a series of con-
> versations with Seth Vidal regarding ways of incorporating the performance
> recommendations for our servers.
> 
> The changes are detailed in the following bugzilla report:
> 
> http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=61841
> 
> The redhat engineer suggested that since it was a feature request it was
> to late in the development cycle that it wouldn't make it into RH 7.3, but
> that it could be more easily incorporated if the next release of nfsutils
> if they were already in the upstream source.
> 

I checked a slightly different patch. Please check it out and make
sure I didn't break anything.

Thanks.


H.J.
---
2002-04-07  H.J. Lu <hjl@lucon.org>

	* etc/redhat/nfs.init: Read /etc/sysconfig/nfsd for NFS tuning.

Index: etc/redhat/nfs.init
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/etc/redhat/nfs.init,v
retrieving revision 1.14
diff -u -p -r1.14 nfs.init
--- etc/redhat/nfs.init	25 Jul 2001 16:23:22 -0000	1.14
+++ etc/redhat/nfs.init	7 Apr 2002 20:49:25 -0000
@@ -8,6 +8,7 @@
 #              networks. This service provides NFS server functionality, \
 #              which is configured via the /etc/exports file.
 # probe: true
+# config: /etc/sysconfig/nfsd
 
 # Source function library.
 . /etc/rc.d/init.d/functions
@@ -27,37 +28,76 @@ fi
 [ -x /usr/sbin/exportfs ] || exit 0
 [ -s /etc/exports ] || exit 0
 
-RQUOTAD=`type -path rpc.rquotad`	# Remote quota server
+# Check for and source configuration file otherwise set defaults
+# TUNE_QUEUE: controls whether to up the size of input queues
+NFSDCFG=/etc/sysconfig/nfsd
+if [ -f "$NFSDCFG" ]; then
+   # Tune nfs server settings
+   . "$NFSDCFG"
+else
+   # Set some defaults
+   TUNE_QUEUE ="no"
+   # Default to NFS version 3.
+   RPCMOUNTDOPTS=""
+fi
+
+# Number of servers to be started by default
+[ -z "$RPCNFSDCOUNT" ] && RPCNFSDCOUNT=8
+
+# Remote quota server
+[ -z "$RQUOTAD" ] && RQUOTAD=`type -path rpc.rquotad`
 
-# Number of servers to be started up by default
-RPCNFSDCOUNT=8
-# Default to NFS version 3.
-RPCMOUNTDOPTS=""
+# Get the initial values for the input sock queues
+# at the time of running the script.
+if [ "$TUNE_QUEUE" = "yes" ]; then
+    RMEM_DEFAULT=`/sbin/sysctl -n net.core.rmem_default`
+    RMEM_MAX=`/sbin/sysctl -n net.core.rmem_max`
+    WMEM_DEFAULT=`/sbin/sysctl -n net.core.wmem_default`
+    WMEM_MAX=`/sbin/sysctl -n net.core.wmem_max`
+    # 256kb recommended minimum size based on SPECsfs NFS benchmarks
+    [ -z "$NFS_QS" ] && NFS_QS=262144
+fi
 
 # See how we were called.
 case "$1" in
   start)
 	# Start daemons.
+	# Apply input queue increase for nfs server
+	if [ "$TUNE_QUEUE" = "yes" ]; then
+ 	    /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null 2>&1
+	    /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
+	    /sbin/sysctl -w net.core.wmem_default=$NFSD_QS >/dev/null 2>&1
+	    /sbin/sysctl -w net.core.wmem_max=$NFSD_QS >/dev/null 2>&1
+	fi
 	action "Starting NFS services: " /usr/sbin/exportfs -r
-	if [ -n "$RQUOTAD" ]; then
-		echo -n "Starting NFS quotas: "
-		daemon rpc.rquotad
-		echo
+	if [ -n "$RQUOTAD" -a "$RQUOTAD" != "no" ]; then
+	    echo -n "Starting NFS quotas: "
+	    daemon rpc.rquotad
+	    echo
 	fi
 	echo -n "Starting NFS daemon: "
 	daemon rpc.nfsd $RPCNFSDCOUNT
 	echo
 
-	# Let's see if we support NFS version 3.
-	/usr/sbin/rpcinfo -u localhost nfs 3 &>/dev/null
-	if [ $? -ne 0 ]; then
+	if [ -z "$RPCMOUNTDOPTS" ]; then
+	    # Let's see if we support NFS version 3.
+	    /usr/sbin/rpcinfo -u localhost nfs 3 &>/dev/null
+	    if [ $? -ne 0 ]; then
 		RPCMOUNTDOPTS="--no-nfs-version 3"
+	    fi
 	fi
 
 	echo -n "Starting NFS mountd: "
 	daemon rpc.mountd $RPCMOUNTDOPTS
 	echo
 	touch /var/lock/subsys/nfs
+	# reset input queue for rest of network services
+	if [ "$TUNE_QUEUE" = "yes" ]; then
+	    /sbin/sysctl -w net.core.rmem_default=$RMEM_DEFAULT >/dev/null 2>&1
+	    /sbin/sysctl -w net.core.rmem_max=$RMEM_MAX >/dev/null 2>&1
+	    /sbin/sysctl -w net.core.wmem_default=$WMEM_DEFAULT >/dev/null 2>&1
+	    /sbin/sysctl -w net.core.wmem_max=$WMEM_MAX >/dev/null 2>&1
+	fi
 	;;
   stop)
 	# Stop daemons.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
