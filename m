From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: don't let nfs_callback_svc exit on unexpected svc_recv errors (try #2)
Date: Tue,  8 Apr 2008 15:40:07 -0400
Message-ID: <1207683608-17550-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41589 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755964AbYDHTkL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 15:40:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When svc_recv returns an unexpected error, nfs_callback_svc will print a
warning and exit. This problematic for several reasons. In particular,
it will cause the reference counts for the thread to be wrong, and no
new thread will be started until all nfs4 mounts are unmounted.

Rather than exiting on error from svc_recv, have the thread do a 1s
sleep and then retry the loop. This is unlikely to cause any harm, and
if the error turns out to be something temporary then it may be able to
recover.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a9f1538..5606ae3 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -59,7 +59,7 @@ module_param_call(callback_tcpport, param_set_port, param_get_int,
 static int
 nfs_callback_svc(void *vrqstp)
 {
-	int err;
+	int err, preverr = 0;
 	struct svc_rqst *rqstp = vrqstp;
 
 	set_freezable();
@@ -74,14 +74,20 @@ nfs_callback_svc(void *vrqstp)
 		 * Listen for a request on the socket
 		 */
 		err = svc_recv(rqstp, MAX_SCHEDULE_TIMEOUT);
-		if (err == -EAGAIN || err == -EINTR)
+		if (err == -EAGAIN || err == -EINTR) {
+			preverr = err;
 			continue;
+		}
 		if (err < 0) {
-			printk(KERN_WARNING
-					"%s: terminating on error %d\n",
-					__FUNCTION__, -err);
-			break;
+			if (err != preverr) {
+				printk(KERN_WARNING "%s: unexpected error "
+					"from svc_recv (%d)\n", __func__, err);
+				preverr = err;
+			}
+			schedule_timeout_uninterruptible(HZ);
+			continue;
 		}
+		preverr = err;
 		svc_process(rqstp);
 	}
 	unlock_kernel();
-- 
1.5.3.6

