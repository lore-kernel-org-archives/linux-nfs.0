Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33127 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbcGSUe3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jul 2016 16:34:29 -0400
Received: by mail-io0-f195.google.com with SMTP id y195so2172277iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jul 2016 13:34:29 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/4] pNFS: Separate handling of NFS4ERR_LAYOUTTRYLATER and RECALLCONFLICT
Date: Tue, 19 Jul 2016 16:33:55 -0400
Message-Id: <1468960437-21449-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1468960437-21449-2-git-send-email-trond.myklebust@primarydata.com>
References: <1468960437-21449-1-git-send-email-trond.myklebust@primarydata.com>
 <1468960437-21449-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They are not the same error, and need to be handled differently.

Fixes: 183d9e7b112aa ("pnfs: rework LAYOUTGET retry handling")
Cc: stable@vger.kernel.org # 4.7
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 23 ++++++++++++++---------
 fs/nfs/pnfs.c     |  1 +
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 519368b98762..ee8efe0a5202 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -437,6 +437,7 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
+		case -NFS4ERR_LAYOUTTRYLATER:
 		case -NFS4ERR_RECALLCONFLICT:
 			exception->delay = 1;
 			return 0;
@@ -7883,11 +7884,12 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 	struct inode *inode = lgp->args.inode;
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layout_hdr *lo;
-	int status = task->tk_status;
+	int nfs4err = task->tk_status;
+	int err, status = 0;
 
 	dprintk("--> %s tk_status => %d\n", __func__, -task->tk_status);
 
-	switch (status) {
+	switch (nfs4err) {
 	case 0:
 		goto out;
 
@@ -7919,12 +7921,11 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 			status = -EOVERFLOW;
 			goto out;
 		}
-		/* Fallthrough */
+		status = -EBUSY;
+		break;
 	case -NFS4ERR_RECALLCONFLICT:
-		nfs4_handle_exception(server, -NFS4ERR_RECALLCONFLICT,
-					exception);
 		status = -ERECALLCONFLICT;
-		goto out;
+		break;
 	case -NFS4ERR_EXPIRED:
 	case -NFS4ERR_BAD_STATEID:
 		exception->timeout = 0;
@@ -7955,9 +7956,13 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 			spin_unlock(&inode->i_lock);
 	}
 
-	status = nfs4_handle_exception(server, status, exception);
-	if (exception->retry)
-		status = -EAGAIN;
+	err = nfs4_handle_exception(server, nfs4err, exception);
+	if (!status) {
+		if (exception->retry)
+			status = -EAGAIN;
+		else
+			status = err;
+	}
 out:
 	dprintk("<-- %s\n", __func__);
 	return status;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 563f131c9abe..c50d4ebab5c5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1648,6 +1648,7 @@ lookup_again:
 	atomic_dec(&lo->plh_outstanding);
 	if (IS_ERR(lseg)) {
 		switch(PTR_ERR(lseg)) {
+		case -EBUSY:
 		case -ERECALLCONFLICT:
 			if (time_after(jiffies, giveup))
 				lseg = NULL;
-- 
2.7.4

