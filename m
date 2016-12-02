Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45370 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751388AbcLBBKS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 20:10:18 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 12:09:44 +1100
Subject: [PATCH 2/4] mount: take history into account when assessing if an
 error is permanent.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148064098395.9179.6844990362226410350.stgit@noble>
In-Reply-To: <148064084082.9179.6570593128436337540.stgit@noble>
References: <148064084082.9179.6570593128436337540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When attempting an NFSv3 mount request, it is possible to catch the
server at an "awkward" moment while it is still starting up.
In these cases it is possible to get an error that would otherwise
indiciate a permanent error, but which should be considered temporary during
the start-up window.

In particular:
 ECONNREFUSED will be returned between the time the network interface
   is configured, and the time that rpcbind starts
 EOPNOTSUPP (representing RPC_PROGNOTREGISTERED) will be returned between
   the time that rpcbind starts and the time when nfsd registers, and
 ESTALE will be returned between the time nfsd starts and when filesystems
   are exported (this windown can be removed with correct configuration).

So these errors only deserve a relatively small timeout.
ECONNREFUSED needs a longer timeout than the others as the start-up
window is longer.  As we have long treated this as a temporary error,
with no complaints, we will keep doing so for now.

So change nfs_is_permanent_error() to record the previous error
and the number of times the same error has been seen.
If ESTALE or EOPNOTSUPP is seen 3 times (over 3 seconds or more)
or ECONNREFUSED is seen 5 times (15 seconds), report a permanent
error, others assume it could be temporary.

A result of this is that if you try a UDP mount from a server which
doesn't support UDP, you get an error without a few seconds, rather
than a 2-minute timeout.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/stropts.c |   34 +++++++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 7b1ad93effc0..387d734e614b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -935,20 +935,44 @@ static int nfs_try_mount(struct nfsmount_info *mi)
  * failed so far, but fail immediately if there is a local
  * error (like a bad mount option).
  *
- * ESTALE is also a temporary error because some servers
- * return ESTALE when a share is temporarily offline.
+ * If there is a remote error, like ESTALE or RPC_PROGNOTREGISTERED
+ * then it is probably permanent, but there is a small chance
+ * the it is temporary can we caught the server at an awkward
+ * time during start-up.  So require that we see three of those
+ * before treating them as permanent.
+ * For ECONNREFUSED, wait a bit longer as there is often a longer
+ * gap between the network being ready and the NFS server starting.
  *
  * Returns 1 if we should fail immediately, or 0 if we
  * should retry.
  */
 static int nfs_is_permanent_error(int error)
 {
+	static int prev_error;
+	static int rpt_cnt;
+
+	if (error == prev_error)
+		rpt_cnt += 1;
+	else
+		rpt_cnt = 1;
+	prev_error = error;
+
 	switch (error) {
 	case ESTALE:
-	case ETIMEDOUT:
+	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
+		/* If two in a row, assume permanent */
+		return rpt_cnt >= 3;
 	case ECONNREFUSED:
+		/* Like the above, this can be temporary during a
+		 * small window.  However it is typically a larger
+		 * window than for the others, and we have historically
+		 * treated this as a temporary (i.e. long timeout)
+		 * error with no complaints, so continue to treat
+		 * it as temporary.
+		 */
+		return 0;	/* temporary */
+	case ETIMEDOUT:
 	case EHOSTUNREACH:
-	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
 	case EAGAIN:
 		return 0;	/* temporary */
 	default:
@@ -1000,7 +1024,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 			if (secs > 10)
 				secs = 10;
 		}
-	};
+	}
 
 	mount_error(mi->spec, mi->node, errno);
 	return EX_FAIL;


