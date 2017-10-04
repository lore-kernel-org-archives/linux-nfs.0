Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36489 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751066AbdJDSw1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Oct 2017 14:52:27 -0400
Received: by mail-io0-f193.google.com with SMTP id f202so1771660ioe.3
        for <linux-nfs@vger.kernel.org>; Wed, 04 Oct 2017 11:52:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4/pnfs: Fix an infinite layoutget loop
Date: Wed,  4 Oct 2017 14:52:22 -0400
Message-Id: <20171004185222.9338-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we can now use a lock stateid or a delegation stateid, that
differs from the context stateid, we need to change the test in
nfs4_layoutget_handle_exception() to take this into account.

This fixes an infinite layoutget loop in the NFS client whereby
it keeps retrying the initial layoutget using the same broken
stateid.

Fixes: 70d2f7b1ea19b ("pNFS: Use the standard I/O stateid when...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6c61e2b99635..f90090e8c959 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8399,8 +8399,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 		lo = NFS_I(inode)->layout;
 		/* If the open stateid was bad, then recover it. */
 		if (!lo || test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
-		    nfs4_stateid_match_other(&lgp->args.stateid,
-					&lgp->args.ctx->state->stateid)) {
+		    !nfs4_stateid_match_other(&lgp->args.stateid, &lo->plh_stateid)) {
 			spin_unlock(&inode->i_lock);
 			exception->state = lgp->args.ctx->state;
 			exception->stateid = &lgp->args.stateid;
-- 
2.13.6

