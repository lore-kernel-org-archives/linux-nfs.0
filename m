From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Typo in Redhat 8/9 nfs start/stop script
Date: 19 Jun 2003 14:27:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1056050865.15737.282.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T53v-0002b4-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 12:27:11 -0700
Received: from mosix.vss.fsi.com (mosix [198.51.27.89])
	by esds.vss.fsi.com (8.11.6+Sun/8.9.1) with ESMTP id h5JJR3K07640
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 14:27:04 -0500 (CDT)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Note for any Redhat users that need higher than default input queues for
NFS.


# Get the initial values for the input sock queues
# at the time of running the script.
if [ "$TUNE_QUEUE" = "yes" ]; then
    RMEM_DEFAULT=`/sbin/sysctl -n net.core.rmem_default`
    RMEM_MAX=`/sbin/sysctl -n net.core.rmem_max`
    # 256kb recommended minimum size based on SPECsfs NFS benchmarks
    [ -z "$NFS_QS" ] && NFS_QS=262144
fi

# See how we were called.
case "$1" in
  start)
        # Start daemons.
        # Apply input queue increase for nfs server
        if [ "$TUNE_QUEUE" = "yes" ]; then
            /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null
2>&1
            /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
        fi



NOTE THAT when checking that the variable has a value and setting the
variable, NFS_QS is used. But when setting the input queues, $NFSD_QS is
used.


-- 
Matt Schillinger

mschilli@vss.fsi.com





-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
