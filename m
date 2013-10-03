Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60468 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754264Ab3JCQXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Oct 2013 12:23:30 -0400
From: <andros@netapp.com>
To: <bryan.schumaker@netapp.com>
CC: <trond.myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 1/1] NFSv4 Remove zeroing state kern warnings
Date: Thu, 3 Oct 2013 12:23:24 -0400
Message-ID: <1380817404-3054-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

As of commit 5d422301f97b821301efcdb6fc9d1a83a5c102d6 we no longer zero the
state.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cc14cbb..fa2706a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1375,8 +1375,8 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 				goto out;
 			default:
-				printk(KERN_ERR "NFS: %s: unhandled error %d. "
-					"Zeroing state\n", __func__, status);
+				printk(KERN_ERR "NFS: %s: unhandled error %d\n",
+					 __func__, status);
 			case -ENOMEM:
 			case -NFS4ERR_DENIED:
 			case -NFS4ERR_RECLAIM_BAD:
@@ -1439,15 +1439,12 @@ restart:
 		}
 		switch (status) {
 			default:
-				printk(KERN_ERR "NFS: %s: unhandled error %d. "
-					"Zeroing state\n", __func__, status);
+				printk(KERN_ERR "NFS: %s: unhandled error %d\n",
+					__func__, status);
 			case -ENOENT:
 			case -ENOMEM:
 			case -ESTALE:
-				/*
-				 * Open state on this file cannot be recovered
-				 * All we can do is revert to using the zero stateid.
-				 */
+				/* Open state on this file cannot be recovered */
 				nfs4_state_mark_recovery_failed(state, status);
 				break;
 			case -EAGAIN:
-- 
1.8.3.1

