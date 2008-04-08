From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: don't let nfs_callback_svc exit on unexpected svc_recv errors
Date: Tue,  8 Apr 2008 09:18:08 -0400
Message-ID: <1207660689-11863-1-git-send-email-jlayton@redhat.com>
Cc: trond.myklebust@fys.uio.no, hch@infradead.org,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39185 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbYDHNST (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 09:18:19 -0400
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
 fs/nfs/callback.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a9f1538..78bc69a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -77,10 +77,11 @@ nfs_callback_svc(void *vrqstp)
 		if (err == -EAGAIN || err == -EINTR)
 			continue;
 		if (err < 0) {
-			printk(KERN_WARNING
-					"%s: terminating on error %d\n",
-					__FUNCTION__, -err);
-			break;
+			if (printk_ratelimit())
+				printk(KERN_WARNING "%s: unexpected error "
+					"from svc_recv (%d)\n", __func__, err);
+			schedule_timeout_uninterruptible(HZ);
+			continue;
 		}
 		svc_process(rqstp);
 	}
-- 
1.5.3.6

