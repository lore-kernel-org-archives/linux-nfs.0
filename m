Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 08/10] NFSv4: Retry NFS4ERR_OLD_STATEID errors in layoutreturn
Date: Fri,  3 Nov 2017 07:35:37 -0400
Message-Id: <20171103113539.5551-9-trond.myklebust@primarydata.com>
In-Reply-To: <20171103113539.5551-8-trond.myklebust@primarydata.com>
References: <20171103113539.5551-1-trond.myklebust@primarydata.com>
 <20171103113539.5551-2-trond.myklebust@primarydata.com>
 <20171103113539.5551-3-trond.myklebust@primarydata.com>
 <20171103113539.5551-4-trond.myklebust@primarydata.com>
 <20171103113539.5551-5-trond.myklebust@primarydata.com>
 <20171103113539.5551-6-trond.myklebust@primarydata.com>
 <20171103113539.5551-7-trond.myklebust@primarydata.com>
 <20171103113539.5551-8-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

If our layoutreturn returns an NFS4ERR_OLD_STATEID, then try to
update the stateid and retry.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1bb0e405aa57..79306a903453 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8766,8 +8766,15 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 
 	server = NFS_SERVER(lrp->args.inode);
 	switch (task->tk_status) {
+	case -NFS4ERR_OLD_STATEID:
+		if (nfs4_refresh_layout_stateid(&lrp->args.stateid,
+					lrp->args.inode)) {
+			goto out_restart;
+		}
+		/* Fallthrough */
 	default:
 		task->tk_status = 0;
+		/* Fallthrough */
 	case 0:
 		break;
 	case -NFS4ERR_DELAY:
@@ -8778,6 +8785,10 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		return;
 	}
 	dprintk("<-- %s\n", __func__);
+	return;
+out_restart:
+	nfs4_sequence_free_slot(&lrp->res.seq_res);
+	rpc_restart_call_prepare(task);
 }
 
 static void nfs4_layoutreturn_release(void *calldata)
-- 
2.13.6
