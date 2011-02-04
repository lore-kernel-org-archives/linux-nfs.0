Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105Ab1BDVec (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:32 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 12/40] pnfs_submit: enforce requested DS only pNFS role
Date: Fri,  4 Feb 2011 16:33:34 -0500
Message-Id: <1296855242-2592-13-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-12-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfs-submit: fail init_clientid if a DS is not really a DS]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayoutdev.c |    5 -----
 fs/nfs/nfs4state.c         |   11 +++++++++++
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 0059375..83b0ab8 100644
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
index 49433aa..3cdbf3b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -229,6 +229,7 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
+	u32 req_exchange_flags = clp->cl_exchange_flags;
 
 	nfs4_begin_drain_session(clp);
 	status = nfs4_proc_exchange_id(clp, cred);
@@ -237,6 +238,16 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	status = nfs4_proc_create_session(clp);
 	if (status != 0)
 		goto out;
+	if (is_ds_only_session(req_exchange_flags)) {
+		clp->cl_exchange_flags &=
+		     ~(EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_NON_PNFS);
+		if (!is_ds_only_session(clp->cl_exchange_flags)) {
+			nfs4_destroy_session(clp->cl_session);
+			clp->cl_session = NULL;
+			status = -ENOTSUPP;
+			goto out;
+		}
+	}
 	nfs41_setup_state_renewal(clp);
 	nfs_mark_client_ready(clp, NFS_CS_READY);
 out:
-- 
1.6.6

