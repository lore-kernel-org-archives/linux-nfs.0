Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46134 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754409Ab2CUTq5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:46:57 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 12/12] NFSv4.1 have filelayout_initiate_commit return void
Date: Wed, 21 Mar 2012 15:46:24 -0400
Message-Id: <1332359184-1887-13-git-send-email-andros@netapp.com>
In-Reply-To: <1332359184-1887-1-git-send-email-andros@netapp.com>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The return is ignored.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index ee0159b..9df7c17 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -972,7 +972,7 @@ select_ds_fh_from_commit(struct pnfs_layout_segment *lseg, u32 i)
 	return flseg->fh_array[i];
 }
 
-static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
+static void filelayout_initiate_commit(struct nfs_write_data *data, int how)
 {
 	struct pnfs_layout_segment *lseg = data->lseg;
 	struct nfs4_pnfs_ds *ds;
@@ -984,7 +984,7 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 	if (!ds) {
 		prepare_to_resend_writes(data);
 		filelayout_commit_release(data);
-		return -EAGAIN;
+		return;
 	}
 	dprintk("%s ino %lu, how %d cl_count %d\n", __func__,
 		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count));
@@ -994,9 +994,9 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
 		data->args.fh = fh;
-	return nfs_initiate_commit(data, ds->ds_clp->cl_rpcclient,
-				   &filelayout_commit_call_ops, how,
-				    RPC_TASK_SOFTCONN);
+	nfs_initiate_commit(data, ds->ds_clp->cl_rpcclient,
+			    &filelayout_commit_call_ops, how,
+			    RPC_TASK_SOFTCONN);
 }
 
 /*
-- 
1.7.6.4

