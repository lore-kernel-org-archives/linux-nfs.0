Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:39372 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932127AbdDGSQI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:16:08 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 27/34] NFS: Clean up nfs4_proc_bind_one_conn_to_session()
Date: Fri, 7 Apr 2017 14:15:21 -0400
Message-ID: <20170407181528.2832-28-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Returning errors directly even lets us remove the goto

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 201ca3f2c4ba..184d57a5098d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7155,8 +7155,6 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
 	};
 	struct rpc_task *task;
 
-	dprintk("--> %s\n", __func__);
-
 	nfs4_copy_sessionid(&args.sessionid, &clp->cl_session->sess_id);
 	if (!(clp->cl_session->flags & SESSION4_BACK_CHAN))
 		args.dir = NFS4_CDFC4_FORE;
@@ -7176,24 +7174,20 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
 		if (memcmp(res.sessionid.data,
 		    clp->cl_session->sess_id.data, NFS4_MAX_SESSIONID_LEN)) {
 			dprintk("NFS: %s: Session ID mismatch\n", __func__);
-			status = -EIO;
-			goto out;
+			return -EIO;
 		}
 		if ((res.dir & args.dir) != res.dir || res.dir == 0) {
 			dprintk("NFS: %s: Unexpected direction from server\n",
 				__func__);
-			status = -EIO;
-			goto out;
+			return -EIO;
 		}
 		if (res.use_conn_in_rdma_mode != args.use_conn_in_rdma_mode) {
 			dprintk("NFS: %s: Server returned RDMA mode = true\n",
 				__func__);
-			status = -EIO;
-			goto out;
+			return -EIO;
 		}
 	}
-out:
-	dprintk("<-- %s status= %d\n", __func__, status);
+
 	return status;
 }
 
-- 
2.12.2

