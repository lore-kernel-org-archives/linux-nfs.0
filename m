From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NLM: don't let lockd exit on unexpected svc_recv errors
Date: Tue,  8 Apr 2008 09:18:09 -0400
Message-ID: <1207660689-11863-2-git-send-email-jlayton@redhat.com>
References: <1207660689-11863-1-git-send-email-jlayton@redhat.com>
Cc: trond.myklebust@fys.uio.no, hch@infradead.org,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39188 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbYDHNSV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 09:18:21 -0400
In-Reply-To: <1207660689-11863-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When svc_recv returns an unexpected error, lockd will print a warning
and exit. This problematic for several reasons. In particular, it will
cause the reference counts for the thread to be wrong, and can lead to a
potential BUG() call.

Rather than exiting on error from svc_recv, have the thread do a 1s
sleep and then retry the loop. This is unlikely to cause any harm, and
if the error turns out to be something temporary then it may be able to
recover.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 66b5c98..147ae95 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -175,10 +175,11 @@ lockd(void *vrqstp)
 		if (err == -EAGAIN || err == -EINTR)
 			continue;
 		if (err < 0) {
-			printk(KERN_WARNING
-			       "lockd: terminating on error %d\n",
-			       -err);
-			break;
+			if (printk_ratelimit())
+				printk(KERN_WARNING "%s: unexpected error "
+					"from svc_recv (%d)\n", __func__, err);
+			schedule_timeout_interruptible(HZ);
+			continue;
 		}
 
 		dprintk("lockd: request from %s\n",
-- 
1.5.3.6

