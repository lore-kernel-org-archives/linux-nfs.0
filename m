Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33590 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759159AbbKSTay (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Nov 2015 14:30:54 -0500
Received: by qgea14 with SMTP id a14so58283626qge.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2015 11:30:53 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: use sliding delay when LAYOUTGET gets NFS4ERR_DELAY
Date: Thu, 19 Nov 2015 14:30:26 -0500
Message-Id: <1447961426-28828-1-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1446667037-28753-1-git-send-email-jeff.layton@primarydata.com>
References: <1446667037-28753-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When LAYOUTGET gets NFS4ERR_DELAY, we currently will wait 15s before
retrying the call. That is a _very_ long time, so add a timeout value to
struct nfs4_layoutget and pass nfs4_async_handle_error a pointer to it.
This allows the RPC engine to use a sliding delay window, instead of a
15s delay.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 2 +-
 include/linux/nfs_xdr.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff5bddc49a2a..39155cfbed6a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7860,7 +7860,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			spin_unlock(&inode->i_lock);
 		goto out_restart;
 	}
-	if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, state, &lgp->timeout) == -EAGAIN)
 		goto out_restart;
 out:
 	dprintk("<-- %s\n", __func__);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 570d630f98ae..11bbae44f4cb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -251,6 +251,7 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_res res;
 	struct rpc_cred *cred;
 	gfp_t gfp_flags;
+	long timeout;
 };
 
 struct nfs4_getdeviceinfo_args {
-- 
2.4.3

