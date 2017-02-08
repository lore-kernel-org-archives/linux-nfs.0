Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32846 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752087AbdBHQak (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 11:30:40 -0500
Received: by mail-it0-f66.google.com with SMTP id e137so15916012itc.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Feb 2017 08:29:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix memory and state leak in _nfs4_open_and_get_state
Date: Wed,  8 Feb 2017 11:29:46 -0500
Message-Id: <20170208162946.5364-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we exit because the file access check failed, we currently
leak the struct nfs4_state. We need to attach it to the
open context before returning.

Fixes: 3efb9722475e ("NFSv4: Refactor _nfs4_open_and_get_state..")
Cc: stable@vger.kernel.org # 3.10+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0a0eaecf9676..8ab520b67a1d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2730,6 +2730,7 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	ret = PTR_ERR(state);
 	if (IS_ERR(state))
 		goto out;
+	ctx->state = state;
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 	if (opendata->o_res.rflags & NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK)
@@ -2755,7 +2756,6 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	if (ret != 0)
 		goto out;
 
-	ctx->state = state;
 	if (d_inode(dentry) == state->inode) {
 		nfs_inode_attach_open_context(ctx);
 		if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
-- 
2.9.3

