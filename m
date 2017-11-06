Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v7 08/10] NFSv4: Retry NFS4ERR_OLD_STATEID errors in layoutreturn
Date: Mon,  6 Nov 2017 10:27:24 -0500
Message-Id: <20171106152726.13755-9-trond.myklebust@primarydata.com>
In-Reply-To: <20171106152726.13755-8-trond.myklebust@primarydata.com>
References: <20171106152726.13755-1-trond.myklebust@primarydata.com>
 <20171106152726.13755-2-trond.myklebust@primarydata.com>
 <20171106152726.13755-3-trond.myklebust@primarydata.com>
 <20171106152726.13755-4-trond.myklebust@primarydata.com>
 <20171106152726.13755-5-trond.myklebust@primarydata.com>
 <20171106152726.13755-6-trond.myklebust@primarydata.com>
 <20171106152726.13755-7-trond.myklebust@primarydata.com>
 <20171106152726.13755-8-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

If our layoutreturn returns an NFS4ERR_OLD_STATEID, then try to
update the stateid and retry.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1bb0e405aa57..f11230db8d25 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8766,18 +8766,27 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 
 	server = NFS_SERVER(lrp->args.inode);
 	switch (task->tk_status) {
+	case -NFS4ERR_OLD_STATEID:
+		if (nfs4_refresh_layout_stateid(&lrp->args.stateid,
+					lrp->args.inode))
+			goto out_restart;
+		/* Fallthrough */
 	default:
 		task->tk_status = 0;
+		/* Fallthrough */
 	case 0:
 		break;
 	case -NFS4ERR_DELAY:
 		if (nfs4_async_handle_error(task, server, NULL, NULL) != -EAGAIN)
 			break;
-		nfs4_sequence_free_slot(&lrp->res.seq_res);
-		rpc_restart_call_prepare(task);
-		return;
+		goto out_restart;
 	}
 	dprintk("<-- %s\n", __func__);
+	return;
+out_restart:
+	task->tk_status = 0;
+	nfs4_sequence_free_slot(&lrp->res.seq_res);
+	rpc_restart_call_prepare(task);
 }
 
 static void nfs4_layoutreturn_release(void *calldata)
-- 
2.13.6
