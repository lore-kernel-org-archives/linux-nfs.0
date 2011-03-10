Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2867 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752226Ab1CJAT2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 19:19:28 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/4] NFSv4.1: Fix the handling of the SEQUENCE status bits
Date: Wed,  9 Mar 2011 19:19:17 -0500
Message-Id: <1299716359-30977-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1299716359-30977-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1299716359-30977-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We want SEQUENCE status bits to be handled by the state manager in order
to avoid threading issues.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 32713dd..7fd1683 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -436,8 +436,8 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		clp = res->sr_session->clp;
 		do_renew_lease(clp, timestamp);
 		/* Check sequence flags */
-		if (atomic_read(&clp->cl_count) > 1)
-			nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
+		if (res->sr_status_flags != 0)
+			nfs4_schedule_lease_recovery(clp);
 		break;
 	case -NFS4ERR_DELAY:
 		/* The server detected a resend of the RPC call and
@@ -5254,8 +5254,13 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 		goto out;
 	}
 	ret = rpc_wait_for_completion_task(task);
-	if (!ret)
+	if (!ret) {
+		struct nfs4_sequence_res *res = task->tk_msg.rpc_resp;
+
+		if (task->tk_status == 0)
+			nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
 		ret = task->tk_status;
+	}
 	rpc_put_task(task);
 out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
-- 
1.7.4

