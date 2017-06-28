Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33866 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753016AbdF1Bqx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jun 2017 21:46:53 -0400
Received: by mail-it0-f65.google.com with SMTP id o202so2009947itc.1
        for <linux-nfs@vger.kernel.org>; Tue, 27 Jun 2017 18:46:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix a race in nfs4_proc_layoutget
Date: Tue, 27 Jun 2017 21:46:49 -0400
Message-Id: <20170628014649.9874-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the task calling layoutget is signalled, then it is possible for the
calls to nfs4_sequence_free_slot() and nfs4_layoutget_prepare() to race,
in which case we leak a slot.
The fix is to move the call to nfs4_sequence_free_slot() into the
nfs4_layoutget_release() so that it gets called at task teardown time.

Fixes: 2e80dbe7ac51 ("NFSv4.1: Close callback races for OPEN, LAYOUTGET...")
Cc: stable@vger.kernel.org # v4.8+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4e43fd1270c4..dbfa18900e25 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8417,6 +8417,7 @@ static void nfs4_layoutget_release(void *calldata)
 	size_t max_pages = max_response_pages(server);
 
 	dprintk("--> %s\n", __func__);
+	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	nfs4_free_pages(lgp->args.layout.pages, max_pages);
 	pnfs_put_layout_hdr(NFS_I(inode)->layout);
 	put_nfs_open_context(lgp->args.ctx);
@@ -8491,7 +8492,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
 	if (status == 0 && lgp->res.layoutp->len)
 		lseg = pnfs_layout_process(lgp);
-	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	if (status)
-- 
2.9.4

