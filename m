Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:59706 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbaGCFFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 01:05:48 -0400
Received: by mail-pd0-f182.google.com with SMTP id y13so13220212pdi.27
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 22:05:48 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 2/3] nfs41: return layout on last close
Date: Thu,  3 Jul 2014 13:05:01 +0800
Message-Id: <1404363902-12943-3-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1404363902-12943-2-git-send-email-tao.peng@primarydata.com>
References: <1404363902-12943-1-git-send-email-tao.peng@primarydata.com>
 <1404363902-12943-2-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If client has valid delegation, do not return layout on close at all.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c | 44 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 43 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b0e5705..81c0d2e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2647,6 +2647,48 @@ static const struct rpc_call_ops nfs4_close_ops = {
 	.rpc_release = nfs4_free_closedata,
 };
 
+static bool nfs4_state_has_opener(struct nfs4_state *state)
+{
+	/* first check existing openers */
+	if (test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0 &&
+	    state->n_rdonly != 0)
+		return true;
+
+	if (test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0 &&
+	    state->n_wronly != 0)
+		return true;
+
+	if (test_bit(NFS_O_RDWR_STATE, &state->flags) != 0 &&
+	    state->n_rdwr != 0)
+		return true;
+
+	return false;
+}
+
+static bool nfs4_roc(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_open_context *ctx;
+	struct nfs4_state *state;
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry(ctx, &nfsi->open_files, list) {
+		state = ctx->state;
+		if (state == NULL)
+			continue;
+		if (nfs4_state_has_opener(state)) {
+			spin_unlock(&inode->i_lock);
+			return false;
+		}
+	}
+	spin_unlock(&inode->i_lock);
+
+	if (nfs4_check_delegation(inode, FMODE_READ))
+		return false;
+
+	return pnfs_roc(inode);
+}
+
 /* 
  * It is possible for data to be read/written from a mem-mapped file 
  * after the sys_close call (which hits the vfs layer as a flush).
@@ -2697,7 +2739,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
-	calldata->roc = pnfs_roc(state->inode);
+	calldata->roc = nfs4_roc(state->inode);
 	nfs_sb_active(calldata->inode->i_sb);
 
 	msg.rpc_argp = &calldata->arg;
-- 
1.9.1

