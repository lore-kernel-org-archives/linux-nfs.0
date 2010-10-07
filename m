Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17731 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758299Ab0JHOzj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 10:55:39 -0400
Received: from localhost.localdomain (mukeshv-lxp.hq.netapp.com [10.58.48.113])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o98EtMpZ008229
	for <linux-nfs@vger.kernel.org>; Fri, 8 Oct 2010 07:55:22 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] pnfs_submit: Restore forgetful mode io draining
Date: Thu,  7 Oct 2010 05:35:45 -0400
Message-Id: <1286444145-12781-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Recent changes to the waitq code removed the wait for io to drain
in the case of a "forgetful" return.  Restore the previous behavior.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    6 +++++-
 fs/nfs/pnfs.c           |    9 +++------
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c854814..7727f592 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5639,7 +5639,11 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
 		return;
 	}
-
+	if (lrp->stateid) {
+		/* Forget the layout, without sending the return */
+		rpc_exit(task, 0);
+		return;
+	}
 	if (nfs4_setup_sequence(server, NULL, &lrp->args.seq_args,
 				&lrp->res.seq_res, 0, task))
 		return;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f573219..eb4dfdf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -612,7 +612,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 static int
 return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
-	      bool wait)
+	      bool wait, const nfs4_stateid *stateid)
 {
 	struct nfs4_layoutreturn *lrp;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -633,6 +633,7 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	lrp->args.return_type = type;
 	lrp->args.range = *range;
 	lrp->args.inode = ino;
+	lrp->stateid = stateid;
 
 	status = nfs4_proc_layoutreturn(lrp, wait);
 out:
@@ -688,11 +689,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 					__func__, status);
 			}
 		}
-
-		if (!stateid)
-			status = return_layout(ino, &arg, type, lo, wait);
-		else
-			pnfs_layoutreturn_release(lo, &arg);
+		status = return_layout(ino, &arg, type, lo, wait, stateid);
 	}
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c72de21..80e6a36 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -277,6 +277,7 @@ struct nfs4_layoutreturn {
 	struct nfs4_layoutreturn_args args;
 	struct nfs4_layoutreturn_res res;
 	struct rpc_cred *cred;
+	const nfs4_stateid *stateid;
 	int rpc_status;
 };
 
-- 
1.7.2.1

