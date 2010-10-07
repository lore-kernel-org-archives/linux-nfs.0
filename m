Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59485 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab0JGQhS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 12:37:18 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] pnfs_submit: enforce requested DS only pNFS role
Date: Thu,  7 Oct 2010 12:37:10 -0700
Message-Id: <1286480230-9418-3-git-send-email-andros@netapp.com>
In-Reply-To: <1286480230-9418-2-git-send-email-andros@netapp.com>
References: <1286480230-9418-1-git-send-email-andros@netapp.com>
 <1286480230-9418-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    5 -----
 fs/nfs/nfs4state.c         |    5 +++++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index e0edf93..1f0ab62 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -183,11 +183,6 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		goto out_put;
 	}
 	/*
-	 * Mask the (possibly) returned EXCHGID4_FLAG_USE_PNFS_MDS pNFS role
-	 * The is_ds_only_session depends on this.
-	 */
-	clp->cl_exchange_flags &= ~EXCHGID4_FLAG_USE_PNFS_MDS;
-	/*
 	 * Set DS lease equal to the MDS lease, renewal is scheduled in
 	 * create_session
 	 */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91584ad..e2fc175 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -188,6 +188,7 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
+	u32 req_exchange_flags = clp->cl_exchange_flags;
 
 	nfs4_begin_drain_session(clp);
 	status = nfs4_proc_exchange_id(clp, cred);
@@ -196,6 +197,10 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	status = nfs4_proc_create_session(clp);
 	if (status != 0)
 		goto out;
+	if (is_ds_only_session(req_exchange_flags))
+		/* Mask the (possibly) returned MDS and non-pNFS roles */
+		clp->cl_exchange_flags &=
+		     ~(EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_NON_PNFS);
 	nfs41_setup_state_renewal(clp);
 	nfs_mark_client_ready(clp, NFS_CS_READY);
 out:
-- 
1.6.6

