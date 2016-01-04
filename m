Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34614 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcADSVp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:45 -0500
Received: by mail-io0-f172.google.com with SMTP id 1so116643062ion.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 01/18] pNFS: Ensure nfs4_layoutget_prepare returns the correct error
Date: Mon,  4 Jan 2016 13:20:59 -0500
Message-Id: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're unable to perform the layoutget due to an invalid open stateid
or a bulk recall, ensure that we return the error so that the caller
can decide on an appropriate action.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 18d862db15b6..fcd7a9039020 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7760,6 +7760,7 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 	struct nfs4_session *session = nfs4_get_session(server);
+	int ret;
 
 	dprintk("--> %s\n", __func__);
 	/* Note the is a race here, where a CB_LAYOUTRECALL can come in
@@ -7770,12 +7771,12 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	if (nfs41_setup_sequence(session, &lgp->args.seq_args,
 				&lgp->res.seq_res, task))
 		return;
-	if (pnfs_choose_layoutget_stateid(&lgp->args.stateid,
+	ret = pnfs_choose_layoutget_stateid(&lgp->args.stateid,
 					  NFS_I(lgp->args.inode)->layout,
 					  &lgp->args.range,
-					  lgp->args.ctx->state)) {
-		rpc_exit(task, NFS4_OK);
-	}
+					  lgp->args.ctx->state);
+	if (ret < 0)
+		rpc_exit(task, ret);
 }
 
 static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
-- 
2.5.0

