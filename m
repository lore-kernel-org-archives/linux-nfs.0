Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36041 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375AbbKCUnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2015 15:43:37 -0500
Received: by qgad10 with SMTP id d10so24006946qga.3
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2015 12:43:36 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC] nfs4: use adaptive backoff when we get NFS4ERR_DELAY on LAYOUTGET
Date: Tue,  3 Nov 2015 15:43:31 -0500
Message-Id: <1446583411-9901-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we end up waiting a full 15s before reissuing the call
because we're passing in NULL for the timeout.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 3 ++-
 include/linux/nfs_xdr.h | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5133bb18830e..b4098319b021 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7872,7 +7872,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			spin_unlock(&inode->i_lock);
 		goto out_restart;
 	}
-	if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, state, &lgp->timeout) == -EAGAIN)
 		goto out_restart;
 out:
 	dprintk("<-- %s\n", __func__);
@@ -7990,6 +7990,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
 	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
+	lgp->timeout = 0;
 
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 52faf7e96c65..0ab65cb7d15b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -250,6 +250,7 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_res res;
 	struct rpc_cred *cred;
 	gfp_t gfp_flags;
+	long timeout;
 };
 
 struct nfs4_getdeviceinfo_args {
-- 
2.4.3

