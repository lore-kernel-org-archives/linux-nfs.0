Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31457 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755700Ab2CHOEV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 09:04:21 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: dan.carpenter@oracle.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH V2] NFSv4.1 handle DS stateid errors
Date: Wed,  7 Mar 2012 18:44:33 -0500
Message-Id: <1331163873-2306-2-git-send-email-andros@netapp.com>
In-Reply-To: <1331163873-2306-1-git-send-email-andros@netapp.com>
References: <1331163873-2306-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Handle DS READ and WRITE stateid errors by recovering the stateid on the MDS.

NFS4ERR_OLD_STATEID is ignored as the client always sends a
state sequenceid of zero for DS READ and WRITE stateids.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c     |    1 +
 fs/nfs/nfs4filelayout.c |   33 ++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4state.c      |    2 ++
 3 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 87f7544..97d5357 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -474,6 +474,7 @@ void nfs_remove_bad_delegation(struct inode *inode)
 		nfs_free_delegation(delegation);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_remove_bad_delegation);
 
 /**
  * nfs_expire_all_delegation_types
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 47e8f34..cdaee60 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -36,6 +36,7 @@
 #include <linux/sunrpc/metrics.h>
 
 #include "internal.h"
+#include "delegation.h"
 #include "nfs4filelayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
@@ -86,12 +87,35 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs_client *clp,
 					 int *reset)
 {
+	struct nfs_server *mds_server;
+	struct nfs_client *mds_client;
+
 	if (task->tk_status >= 0)
 		return 0;
-
 	*reset = 0;
+	if (state != NULL) {
+		mds_server = NFS_SERVER(state->inode);
+		mds_client = mds_server->nfs_client;
+	}
 
 	switch (task->tk_status) {
+	/* MDS state errors */
+	case -NFS4ERR_DELEG_REVOKED:
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_BAD_STATEID:
+		if (state != NULL)
+			nfs_remove_bad_delegation(state->inode);
+	case -NFS4ERR_OPENMODE:
+		if (state == NULL)
+			break;
+		nfs4_schedule_stateid_recovery(mds_server, state);
+		goto wait_on_recovery;
+	case -NFS4ERR_EXPIRED:
+		if (state != NULL)
+			nfs4_schedule_stateid_recovery(mds_server, state);
+		nfs4_schedule_lease_recovery(mds_client);
+		goto wait_on_recovery;
+	/* DS session errors */
 	case -NFS4ERR_BADSESSION:
 	case -NFS4ERR_BADSLOT:
 	case -NFS4ERR_BAD_HIGH_SLOT:
@@ -117,8 +141,15 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		*reset = 1;
 		break;
 	}
+out:
 	task->tk_status = 0;
 	return -EAGAIN;
+wait_on_recovery:
+	rpc_sleep_on(&mds_client->cl_rpcwaitq, task, NULL);
+	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
+		rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
+	goto out;
+
 }
 
 /* NFS_PROTO call done callback routines */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1dad5c5..a58d02a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1072,6 +1072,7 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 	nfs4_schedule_state_manager(clp);
 }
+EXPORT_SYMBOL_GPL(nfs4_schedule_lease_recovery);
 
 void nfs4_schedule_path_down_recovery(struct nfs_client *clp)
 {
@@ -1109,6 +1110,7 @@ void nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4
 	nfs4_state_mark_reclaim_nograce(clp, state);
 	nfs4_schedule_state_manager(clp);
 }
+EXPORT_SYMBOL_GPL(nfs4_schedule_stateid_recovery);
 
 void nfs_inode_find_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid)
-- 
1.7.6.4

