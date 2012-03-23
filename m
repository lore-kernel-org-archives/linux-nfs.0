Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60949 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447Ab2CWCgQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 22:36:16 -0400
Message-ID: <4F6BE193.5050103@panasas.com>
Date: Thu, 22 Mar 2012 19:36:03 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, "Welch, Brent" <welch@panasas.com>
Subject: SQUASHME: osd_login: Add autologin script for objlayoutdriver
References: <4F62DADD.3010502@panasas.com> <4F62DD6C.4040504@panasas.com>
In-Reply-To: <4F62DD6C.4040504@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/15/2012 11:27 PM, Boaz Harrosh wrote:
> From: Sachin Bhamare <sbhamare@panasas.com>
> 
> This script is part of the autologin feature mandated by the
> pnfs-objects standard.
> It is called from objlayoutdriver.ko in the kernel.
> 
> Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

As suggested by Trond (Thanks Trond) We add a watchdog
facility to the script so it will timeout after 15s and
will return to the Kernel, even if iscsiadm gets stuck.

We are also logging with the "osd_login" prefix.

Below is the diff from this patch. (ver 1).

I will send a new email patch [version 2] for submission
to nfs-utils, as reply to the original patch.

Please submit, as the Kernel part has been accepted
into Mainline for the 3.4-rc1 merge window

Much obliged
Sachin & Boaz

---
diff --git a/utils/osd_login/osd_login b/utils/osd_login/osd_login
index c08e05c..63967fc 100755
--- a/utils/osd_login/osd_login
+++ b/utils/osd_login/osd_login
@@ -27,6 +27,9 @@ PATH="/sbin:/usr/sbin:/bin:/usr/bin"
 
 iscsiadm=/sbin/iscsiadm
 
+PARENT_PID=$BASHPID
+WATCHDOG_TIMEOUT=15
+
 protocol=""
 portal=""
 uri=""
@@ -71,32 +74,45 @@ parse_cmdline()
 	portal=`echo $uri | awk -F '//' '{print $2}'`
 }
 
-do_cmd()
+watchdog()
 {
-	$* 2>&1 | logger &
+	timeout=$1
+	portal=$2
+
+        sleep $timeout
+	if kill -9 $PARENT_PID; then
+	    echo "watchdog : Timed out (>$timeout seconds) while login into $portal" | logger -t "osd_login"
+	fi
+        echo "watchdog: exiting .."
+        exit 2
 }
 
 login_iscsi_osd()
 {
-	echo "osd_login: login into: $1"
+	echo "login into: $1"
 	if ! $iscsiadm -m discovery -o nonpersistent -t sendtargets -p $1 --login; then
 		echo "$iscsiadm -m discovery -t sendtargets -p $1 --login returned error $? !"
 		sleep 1;
 	fi
 }
 
- echo "============= osd_login ========="
- echo "progname : $0"
+echo "============= osd_login ========="
+echo "progname : $0"
 parse_cmdline "$@"
 echo "protocol: $protocol"
 echo "portal: $portal"
 
+watchdog $WATCHDOG_TIMEOUT $portal &
+watchdog_pid=$!
+
 case $protocol in
 iscsi)
-	login_iscsi_osd $portal |& logger
+	login_iscsi_osd $portal |& logger -t "osd_login"
 	;;
 *)
-	echo "osd_login: Error: protocol $protocol not supported !" | logger
+	echo "Error: protocol $protocol not supported !" | logger -t "osd_login"
 	;;
 esac
 
+kill -9 $watchdog_pid
+exit 0
