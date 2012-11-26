Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756005Ab2KZURN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:13 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 24/28] NFSv4: Move nfs4_wait_clnt_recover and nfs4_client_recover_expired_lease
Date: Mon, 26 Nov 2012 15:16:41 -0500
Message-Id: <1353961005-63874-25-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-24-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-19-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-20-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-21-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-22-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-23-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-24-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_wait_clnt_recover and nfs4_client_recover_expired_lease are both
generic state related functions. As such, they belong in nfs4state.c,
and not nfs4proc.c

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |  4 ++++
 fs/nfs/nfs4proc.c  | 36 ------------------------------------
 fs/nfs/nfs4state.c | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 16b1937..2f6a9f9 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -11,6 +11,8 @@
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 
+#define NFS4_MAX_LOOP_ON_RECOVER (10)
+
 struct idmap;
 
 enum nfs4_client_state {
@@ -360,6 +362,8 @@ extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs_inode_find_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
+extern int nfs4_wait_clnt_recover(struct nfs_client *clp);
+extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 45c5d7b..ff7daa0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -70,8 +70,6 @@
 #define NFS4_POLL_RETRY_MIN	(HZ/10)
 #define NFS4_POLL_RETRY_MAX	(15*HZ)
 
-#define NFS4_MAX_LOOP_ON_RECOVER (10)
-
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
@@ -255,22 +253,6 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	kunmap_atomic(start);
 }
 
-static int nfs4_wait_clnt_recover(struct nfs_client *clp)
-{
-	int res;
-
-	might_sleep();
-
-	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-	if (res)
-		return res;
-
-	if (clp->cl_cons_state < 0)
-		return clp->cl_cons_state;
-	return 0;
-}
-
 static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 {
 	int res = 0;
@@ -1884,24 +1866,6 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	return 0;
 }
 
-static int nfs4_client_recover_expired_lease(struct nfs_client *clp)
-{
-	unsigned int loop;
-	int ret;
-
-	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
-		ret = nfs4_wait_clnt_recover(clp);
-		if (ret != 0)
-			break;
-		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
-		    !test_bit(NFS4CLNT_CHECK_LEASE,&clp->cl_state))
-			break;
-		nfs4_schedule_state_manager(clp);
-		ret = -EIO;
-	}
-	return ret;
-}
-
 static int nfs4_recover_expired_lease(struct nfs_server *server)
 {
 	return nfs4_client_recover_expired_lease(server->nfs_client);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4a4c896..1d38c8b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1216,6 +1216,40 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_lease_recovery);
 
+int nfs4_wait_clnt_recover(struct nfs_client *clp)
+{
+	int res;
+
+	might_sleep();
+
+	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
+			nfs_wait_bit_killable, TASK_KILLABLE);
+	if (res)
+		return res;
+
+	if (clp->cl_cons_state < 0)
+		return clp->cl_cons_state;
+	return 0;
+}
+
+int nfs4_client_recover_expired_lease(struct nfs_client *clp)
+{
+	unsigned int loop;
+	int ret;
+
+	for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
+		ret = nfs4_wait_clnt_recover(clp);
+		if (ret != 0)
+			break;
+		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
+		    !test_bit(NFS4CLNT_CHECK_LEASE,&clp->cl_state))
+			break;
+		nfs4_schedule_state_manager(clp);
+		ret = -EIO;
+	}
+	return ret;
+}
+
 /*
  * nfs40_handle_cb_pathdown - return all delegations after NFS4ERR_CB_PATH_DOWN
  * @clp: client to process
-- 
1.7.11.7

