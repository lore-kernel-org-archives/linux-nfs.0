Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60597 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755249Ab2C0WgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Mar 2012 18:36:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4.1: Fix layoutcommit error handling
Date: Tue, 27 Mar 2012 18:35:43 -0400
Message-Id: <1332887744-4222-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Firstly, task->tk_status will always return negative error values,
so the current tests for 'NFS4ERR_DELEG_REVOKED' etc. are all being
ignored.
Secondly, clean up the code so that we only need to test
task->tk_status once!

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4proc.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ee9ca19..1933e67 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6112,21 +6112,22 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 		return;
 
 	switch (task->tk_status) { /* Just ignore these failures */
-	case NFS4ERR_DELEG_REVOKED: /* layout was recalled */
-	case NFS4ERR_BADIOMODE:     /* no IOMODE_RW layout for range */
-	case NFS4ERR_BADLAYOUT:     /* no layout */
-	case NFS4ERR_GRACE:	    /* loca_recalim always false */
+	case -NFS4ERR_DELEG_REVOKED: /* layout was recalled */
+	case -NFS4ERR_BADIOMODE:     /* no IOMODE_RW layout for range */
+	case -NFS4ERR_BADLAYOUT:     /* no layout */
+	case -NFS4ERR_GRACE:	    /* loca_recalim always false */
 		task->tk_status = 0;
-	}
-
-	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
-		rpc_restart_call_prepare(task);
-		return;
-	}
-
-	if (task->tk_status == 0)
+		break;
+	case 0:
 		nfs_post_op_update_inode_force_wcc(data->args.inode,
 						   data->res.fattr);
+		break;
+	default:
+		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
+			rpc_restart_call_prepare(task);
+			return;
+		}
+	}
 }
 
 static void nfs4_layoutcommit_release(void *calldata)
-- 
1.7.7.6

