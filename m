Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:16437 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932260AbcHKVlg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 17:41:36 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 8 12/12] NFS pnfs data server multipath session trunking
Date: Thu, 11 Aug 2016 17:39:34 -0400
Message-ID: <1470951574-18441-13-git-send-email-andros@netapp.com>
In-Reply-To: <1470951574-18441-1-git-send-email-andros@netapp.com>
References: <1470951574-18441-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Try all multipath addresses for a data server. The first address that
successfully connects and creates a session is the DS mount address.
All subsequent addresses are tested for session trunking and
added as aliases.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h |  3 +++
 fs/nfs/nfs4_fs.h  |  1 +
 fs/nfs/nfs4proc.c | 33 ++++++++++++++++++++++++++++++++
 fs/nfs/pnfs_nfs.c | 56 +++++++++++++++++++++++++++++++++++++++++--------------
 4 files changed, 79 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8de509b..4f4e775 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -569,6 +569,9 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
+extern int nfs4_test_session_trunk(struct rpc_clnt *,
+				struct rpc_xprt *,
+				void *);
 
 static inline struct inode *nfs_igrab_and_active(struct inode *inode)
 {
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b2a94ca..e7d2efe 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -59,6 +59,7 @@ struct nfs4_minor_version_ops {
 			struct nfs4_lock_state *);
 	struct nfs_seqid *
 		(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
+	int	(*session_trunk)(struct rpc_clnt *, struct rpc_xprt *, void *);
 	const struct rpc_call_ops *call_sync_ops;
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ffe578c..3770f03 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7307,6 +7307,37 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE, NULL);
 }
 
+/**
+ * nfs4_test_session_trunk
+ *
+ * This is an add_xprt_test() test function called from
+ * rpc_clnt_setup_test_and_add_xprt.
+ *
+ * The rpc_xprt_switch is referrenced by rpc_clnt_setup_test_and_add_xprt
+ * and is dereferrenced in nfs4_exchange_id_release
+ *
+ * Upon success, add the new transport to the rpc_clnt
+ *
+ * @clnt: struct rpc_clnt to get new transport
+ * @xprt: the rpc_xprt to test
+ * @data: call data for _nfs4_proc_exchange_id.
+ */
+int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
+			    void *data)
+{
+	struct nfs4_add_xprt_data *adata = (struct nfs4_add_xprt_data *)data;
+	u32 sp4_how;
+
+	dprintk("--> %s try %s\n", __func__,
+		xprt->address_strings[RPC_DISPLAY_ADDR]);
+
+	sp4_how = (adata->clp->cl_sp4_flags == 0 ? SP4_NONE : SP4_MACH_CRED);
+
+	/* Test connection for session trunking. Async exchange_id call */
+	return  _nfs4_proc_exchange_id(adata->clp, adata->cred, sp4_how, xprt);
+}
+EXPORT_SYMBOL_GPL(nfs4_test_session_trunk);
+
 static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
 		struct rpc_cred *cred)
 {
@@ -8885,6 +8916,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
 	.alloc_seqid = nfs_alloc_no_seqid,
+	.session_trunk = nfs4_test_session_trunk,
 	.call_sync_ops = &nfs41_call_sync_ops,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
@@ -8914,6 +8946,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 	.free_lock_state = nfs41_free_lock_state,
 	.call_sync_ops = &nfs41_call_sync_ops,
 	.alloc_seqid = nfs_alloc_no_seqid,
+	.session_trunk = nfs4_test_session_trunk,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index f3468b5..242ce87 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -690,13 +690,48 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 		dprintk("%s: DS %s: trying address %s\n",
 			__func__, ds->ds_remotestr, da->da_remotestr);
 
-		clp = nfs4_set_ds_client(mds_srv,
-					(struct sockaddr *)&da->da_addr,
-					da->da_addrlen, IPPROTO_TCP,
-					timeo, retrans, minor_version,
-					au_flavor);
-		if (!IS_ERR(clp))
-			break;
+		if (!IS_ERR(clp) && clp->cl_mvops->session_trunk) {
+			struct xprt_create xprt_args = {
+				.ident = XPRT_TRANSPORT_TCP,
+				.net = clp->cl_net,
+				.dstaddr = (struct sockaddr *)&da->da_addr,
+				.addrlen = da->da_addrlen,
+				.servername = clp->cl_hostname,
+			};
+			struct nfs4_add_xprt_data xprtdata = {
+				.clp = clp,
+				.cred = nfs4_get_clid_cred(clp),
+			};
+			struct rpc_add_xprt_test rpcdata = {
+				.add_xprt_test = clp->cl_mvops->session_trunk,
+				.data = &xprtdata,
+			};
+
+			/**
+			* Test this address for session trunking and
+			* add as an alias
+			*/
+			rpc_clnt_add_xprt(clp->cl_rpcclient, &xprt_args,
+					  rpc_clnt_setup_test_and_add_xprt,
+					  &rpcdata);
+		} else {
+			clp = nfs4_set_ds_client(mds_srv,
+						(struct sockaddr *)&da->da_addr,
+						da->da_addrlen, IPPROTO_TCP,
+						timeo, retrans, minor_version,
+						au_flavor);
+			if (IS_ERR(clp))
+				continue;
+
+			status = nfs4_init_ds_session(clp,
+					mds_srv->nfs_client->cl_lease_time);
+			if (status) {
+				nfs_put_client(clp);
+				clp = ERR_PTR(-EIO);
+				continue;
+			}
+
+		}
 	}
 
 	if (IS_ERR(clp)) {
@@ -704,18 +739,11 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 		goto out;
 	}
 
-	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
-	if (status)
-		goto out_put;
-
 	smp_wmb();
 	ds->ds_clp = clp;
 	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
 out:
 	return status;
-out_put:
-	nfs_put_client(clp);
-	goto out;
 }
 
 /*
-- 
1.8.3.1

