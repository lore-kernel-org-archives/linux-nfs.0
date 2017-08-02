Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18841 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752965AbdHBL1w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Aug 2017 07:27:52 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4: Don't add a new lock on an interrupted wait for LOCK
Date: Wed,  2 Aug 2017 07:27:51 -0400
Message-Id: <cda7d9d6f145289d2855eb733a8d795938e67453.1501673116.git.bcodding@redhat.com>
In-Reply-To: <1501618320.4702.14.camel@redhat.com>
References: <1501618320.4702.14.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the wait for a LOCK operation is interrupted, and then the file is
closed, the locks cleanup code will assume that no new locks will be added
to the inode after it has completed.  We already have a mechanism to detect
if there was signal, so let's use that to avoid recreating the local lock
once the RPC completes.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dbfa18900e25..5256f429c268 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6100,7 +6100,7 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 	case 0:
 		renew_lease(NFS_SERVER(d_inode(data->ctx->dentry)),
 				data->timestamp);
-		if (data->arg.new_lock) {
+		if (data->arg.new_lock && !data->cancelled) {
 			data->fl.fl_flags &= ~(FL_SLEEP | FL_ACCESS);
 			if (locks_lock_inode_wait(lsp->ls_state->inode, &data->fl) < 0) {
 				rpc_restart_call_prepare(task);
-- 
2.9.3

