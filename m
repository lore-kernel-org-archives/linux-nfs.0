Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36562 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726762AbeILBYt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 21:24:49 -0400
Received: by mail-qt0-f193.google.com with SMTP id t5-v6so29734982qtn.3
        for <linux-nfs@vger.kernel.org>; Tue, 11 Sep 2018 13:23:52 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: Reduce indentation of the switch statement in nfs4_reclaim_open_state()
Date: Tue, 11 Sep 2018 16:23:47 -0400
Message-Id: <20180911202348.23160-2-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180911202348.23160-1-Anna.Schumaker@Netapp.com>
References: <20180911202348.23160-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Most places in the kernel tend to line up cases with the switch to
reduce indentation, so move this over to match that style.
Additionally, I handle the (status >= 0) case in the switch so that we
only "goto restart" from a single place after error handling.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4state.c | 70 ++++++++++++++++++++++------------------------
 1 file changed, 33 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index aa46a3216d60..8a399dc17e19 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1615,46 +1615,42 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 		atomic_inc(&state->count);
 		spin_unlock(&sp->so_lock);
 		status = __nfs4_reclaim_open_state(sp, state, ops);
-		if (status >= 0) {
-			nfs4_put_open_state(state);
-			spin_lock(&sp->so_lock);
-			goto restart;
-		}
 
 		switch (status) {
-			default:
-				printk(KERN_ERR "NFS: %s: unhandled error %d\n",
-					__func__, status);
-				/* Fall through */
-			case -ENOENT:
-			case -ENOMEM:
-			case -EACCES:
-			case -EROFS:
-			case -EIO:
-			case -ESTALE:
-				/* Open state on this file cannot be recovered */
-				nfs4_state_mark_recovery_failed(state, status);
-				break;
-			case -EAGAIN:
-				ssleep(1);
-				/* Fall through */
-			case -NFS4ERR_ADMIN_REVOKED:
-			case -NFS4ERR_STALE_STATEID:
-			case -NFS4ERR_OLD_STATEID:
-			case -NFS4ERR_BAD_STATEID:
-			case -NFS4ERR_RECLAIM_BAD:
-			case -NFS4ERR_RECLAIM_CONFLICT:
-				nfs4_state_mark_reclaim_nograce(sp->so_server->nfs_client, state);
+		default:
+			if (status >= 0)
 				break;
-			case -NFS4ERR_EXPIRED:
-			case -NFS4ERR_NO_GRACE:
-				nfs4_state_mark_reclaim_nograce(sp->so_server->nfs_client, state);
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_BADSESSION:
-			case -NFS4ERR_BADSLOT:
-			case -NFS4ERR_BAD_HIGH_SLOT:
-			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
-				goto out_err;
+			printk(KERN_ERR "NFS: %s: unhandled error %d\n", __func__, status);
+			/* Fall through */
+		case -ENOENT:
+		case -ENOMEM:
+		case -EACCES:
+		case -EROFS:
+		case -EIO:
+		case -ESTALE:
+			/* Open state on this file cannot be recovered */
+			nfs4_state_mark_recovery_failed(state, status);
+			break;
+		case -EAGAIN:
+			ssleep(1);
+			/* Fall through */
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_STALE_STATEID:
+		case -NFS4ERR_OLD_STATEID:
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_RECLAIM_BAD:
+		case -NFS4ERR_RECLAIM_CONFLICT:
+			nfs4_state_mark_reclaim_nograce(sp->so_server->nfs_client, state);
+			break;
+		case -NFS4ERR_EXPIRED:
+		case -NFS4ERR_NO_GRACE:
+			nfs4_state_mark_reclaim_nograce(sp->so_server->nfs_client, state);
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BAD_HIGH_SLOT:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+			goto out_err;
 		}
 		nfs4_put_open_state(state);
 		spin_lock(&sp->so_lock);
-- 
2.18.0
