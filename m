Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47855 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab2HBIrY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 04:47:24 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so4129902bkw.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2012 01:47:23 -0700 (PDT)
From: Idan Kedar <idank@tonian.com>
To: coredev@tonian.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH v2 2/2] pnfs: nfs4_proc_layoutget returns void
Date: Thu,  2 Aug 2012 11:47:11 +0300
Message-Id: <1343897231-30205-3-git-send-email-idank@tonian.com>
In-Reply-To: <1343897231-30205-1-git-send-email-idank@tonian.com>
References: <1343897231-30205-1-git-send-email-idank@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

since the only user of nfs4_proc_layoutget is send_layoutget, which
ignores its return value, there is no reason to return any value.

Signed-off-by: Idan Kedar <idank@tonian.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/nfs4proc.c |    8 ++++----
 fs/nfs/pnfs.h     |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1a1776b..a87216d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6227,7 +6227,7 @@ static const struct rpc_call_ops nfs4_layoutget_call_ops = {
 	.rpc_release = nfs4_layoutget_release,
 };
 
-int nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
+void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 {
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 	size_t max_pages = max_response_pages(server);
@@ -6251,7 +6251,7 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	lgp->args.layout.pages = nfs4_alloc_pages(max_pages, gfp_flags);
 	if (!lgp->args.layout.pages) {
 		nfs4_layoutget_release(lgp);
-		return -ENOMEM;
+		return;
 	}
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
 
@@ -6260,7 +6260,7 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	nfs41_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
-		return PTR_ERR(task);
+		return;
 	status = nfs4_wait_for_completion_rpc_task(task);
 	if (status == 0)
 		status = task->tk_status;
@@ -6268,7 +6268,7 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 		status = pnfs_layout_process(lgp);
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
-	return status;
+	return;
 }
 
 static void
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9a31ff3..eda42b9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -171,7 +171,7 @@ extern int nfs4_proc_getdevicelist(struct nfs_server *server,
 				   struct pnfs_devicelist *devlist);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
-extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
+extern void nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
-- 
1.7.6.5

