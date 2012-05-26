Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8849 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752826Ab2EZSkY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 May 2012 14:40:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH v2 7/9] NFSv4.1: Ensure we use the correct credentials for bind_conn_to_session
Date: Sat, 26 May 2012 14:39:58 -0400
Message-Id: <1338057600-11130-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338057600-11130-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1338057600-11130-1-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-2-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-3-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com>
 <1338057600-11130-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    2 +-
 fs/nfs/nfs4proc.c  |    3 ++-
 fs/nfs/nfs4state.c |    9 ++++++++-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a5dbe62..f730730 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -212,7 +212,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
 extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-extern int nfs4_proc_bind_conn_to_session(struct nfs_client *);
+extern int nfs4_proc_bind_conn_to_session(struct nfs_client *, struct rpc_cred *cred);
 extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8fa3a36..3fdff0c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5105,7 +5105,7 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
  * The 4.1 client currently uses the same TCP connection for the
  * fore and backchannel.
  */
-int nfs4_proc_bind_conn_to_session(struct nfs_client *clp)
+int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
 	struct nfs41_bind_conn_to_session_res res;
@@ -5114,6 +5114,7 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp)
 			&nfs4_procedures[NFSPROC4_CLNT_BIND_CONN_TO_SESSION],
 		.rpc_argp = clp,
 		.rpc_resp = &res,
+		.rpc_cred = cred,
 	};
 
 	dprintk("--> %s\n", __func__);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1587840..7dbca66 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1779,7 +1779,14 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 
 static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 {
-	return nfs4_proc_bind_conn_to_session(clp);
+	struct rpc_cred *cred;
+	int ret;
+
+	cred = nfs4_get_exchange_id_cred(clp);
+	ret = nfs4_proc_bind_conn_to_session(clp, cred);
+	if (cred)
+		put_rpccred(cred);
+	return ret;
 }
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
-- 
1.7.7.6

