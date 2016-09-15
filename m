Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34744 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756895AbcIOW0P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 18:26:15 -0400
Received: by mail-io0-f193.google.com with SMTP id y139so386784ioy.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 15:26:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Fix atime updates on pNFS clients
Date: Thu, 15 Sep 2016 18:26:05 -0400
Message-Id: <1473978365-58024-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the code so that we always mark the atime as invalid in nfs4_read_done().
Currently, the expectation appears to be that the pNFS drivers should always
do this, with the result that most of them don't.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/internal.h | 1 -
 fs/nfs/nfs4proc.c | 8 ++------
 fs/nfs/pnfs.c     | 4 +---
 3 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 74935a19e4bf..52faaf516dd5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -563,7 +563,6 @@ void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
 
 /* nfs4proc.c */
-extern void __nfs4_read_done_cb(struct nfs_pgio_header *);
 extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 			    const struct nfs_client_initdata *);
 extern int nfs40_walk_client_list(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 08c6e46c5b95..9b82c827fe03 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4530,11 +4530,6 @@ static bool nfs4_error_stateid_expired(int err)
 	return false;
 }
 
-void __nfs4_read_done_cb(struct nfs_pgio_header *hdr)
-{
-	nfs_invalidate_atime(hdr->inode);
-}
-
 static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_pgio_header *hdr)
 {
 	struct nfs_server *server = NFS_SERVER(hdr->inode);
@@ -4554,7 +4549,6 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_pgio_header *hdr)
 		}
 	}
 
-	__nfs4_read_done_cb(hdr);
 	if (task->tk_status > 0)
 		renew_lease(server, hdr->timestamp);
 	return 0;
@@ -4583,6 +4577,8 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 		return -EAGAIN;
 	if (nfs4_read_stateid_changed(task, &hdr->args))
 		return -EAGAIN;
+	if (task->tk_status > 0)
+		nfs_invalidate_atime(hdr->inode);
 	return hdr->pgio_done_cb ? hdr->pgio_done_cb(task, hdr) :
 				    nfs4_read_done_cb(task, hdr);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2c93a85eda51..ebc8dffe09ba 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2185,10 +2185,8 @@ static void pnfs_ld_handle_read_error(struct nfs_pgio_header *hdr)
  */
 void pnfs_ld_read_done(struct nfs_pgio_header *hdr)
 {
-	if (likely(!hdr->pnfs_error)) {
-		__nfs4_read_done_cb(hdr);
+	if (likely(!hdr->pnfs_error))
 		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
-	}
 	trace_nfs4_pnfs_read(hdr, hdr->pnfs_error);
 	if (unlikely(hdr->pnfs_error))
 		pnfs_ld_handle_read_error(hdr);
-- 
2.7.4

