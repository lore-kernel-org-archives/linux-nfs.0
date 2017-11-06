Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v8 08/11] NFSv4: Retry NFS4ERR_OLD_STATEID errors in layoutreturn
Date: Mon,  6 Nov 2017 15:28:08 -0500
Message-Id: <20171106202811.70202-9-trond.myklebust@primarydata.com>
In-Reply-To: <20171106202811.70202-8-trond.myklebust@primarydata.com>
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
 <20171106202811.70202-2-trond.myklebust@primarydata.com>
 <20171106202811.70202-3-trond.myklebust@primarydata.com>
 <20171106202811.70202-4-trond.myklebust@primarydata.com>
 <20171106202811.70202-5-trond.myklebust@primarydata.com>
 <20171106202811.70202-6-trond.myklebust@primarydata.com>
 <20171106202811.70202-7-trond.myklebust@primarydata.com>
 <20171106202811.70202-8-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

If our layoutreturn returns an NFS4ERR_OLD_STATEID, then try to
update the stateid and retry.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d91586fad2bd..0d6941d548f8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8767,18 +8767,27 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 
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
