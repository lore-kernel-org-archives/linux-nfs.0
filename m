From: domen@coderock.org
Subject: [patch 2/2] fs/nfs4callback: replace schedule_timeout() with ssleep()
Date: Sun, 06 Mar 2005 11:39:23 +0100
Message-ID: <20050306103924.1E9011F205@trashy.coderock.org>
Cc: nfs@lists.sourceforge.net, domen@coderock.org, nacc@us.ibm.com
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7tAY-0008Fv-2r
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 02:39:30 -0800
Received: from coderock.org
	([193.77.147.115] helo=trashy.coderock.org ident=postfix)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D7tAX-0006Ak-5c
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 02:39:29 -0800
To: neilb@cse.unsw.edu.au
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>




Use ssleep() instead of schedule_timeout() to guarantee the task
delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/fs/nfsd/nfs4callback.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN fs/nfsd/nfs4callback.c~ssleep-fs_nfsd_nfs4callback fs/nfsd/nfs4callback.c
--- kj/fs/nfsd/nfs4callback.c~ssleep-fs_nfsd_nfs4callback	2005-03-05 16:11:18.000000000 +0100
+++ kj-domen/fs/nfsd/nfs4callback.c	2005-03-05 16:11:18.000000000 +0100
@@ -38,6 +38,7 @@
 #include <linux/list.h>
 #include <linux/inet.h>
 #include <linux/errno.h>
+#include <linux/delay.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/clnt.h>
@@ -531,8 +532,7 @@ out:
 retry:
 	atomic_inc(&dp->dl_recall_cnt);
 	/* sleep 2 seconds before retrying recall */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(2*HZ);
+	ssleep(2);
 	status = nfsd4_cb_recall(dp);
 	dprintk("NFSD: nfs4_cb_recall_done: retry status: %d  dp %p dl_flock %p\n",status,dp, dp->dl_flock);
 }
_


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
