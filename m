Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32047 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736Ab1EJRXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 May 2011 13:23:44 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: trond@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: use scope from exchange_id to skip reclaim
Date: Tue, 10 May 2011 13:23:15 -0400
Message-Id: <1305048195-24377-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

>From Section 8.4.2.1 of the rfc 5661 - We can determine if a RECLAIM_REBOOT
can be skipped if the "eir_server_scope" from the exchange_id proc differs from
previous calls.

Also, in the future server_scope will be useful for determining whether client
trunking is available

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---

Applied comments from Benny. Also, I added a dprintk when server_scope mismatch
is detected.


 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4_fs.h          |    2 ++
 fs/nfs/nfs4proc.c         |   32 ++++++++++++++++++++++++++++++++
 fs/nfs/nfs4state.c        |    9 ++++++++-
 fs/nfs/nfs4xdr.c          |    8 +++++++-
 include/linux/nfs_fs_sb.h |    3 +++
 include/linux/nfs_xdr.h   |    1 +
 7 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 139be96..ba96834 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -291,6 +291,7 @@ static void nfs_free_client(struct nfs_client *clp)
 		put_rpccred(clp->cl_machine_cred);
 
 	kfree(clp->cl_hostname);
+	kfree(clp->server_scope);
 	kfree(clp);
 
 	dprintk("<-- nfs_free_client()\n");
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c4a6983..bfde1c1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -48,6 +48,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
+	NFS4CLNT_SERVER_SCOPE_MISMATCH,
 };
 
 enum nfs4_session_state {
@@ -349,6 +350,7 @@ extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_recall_slot(struct nfs_client *clp);
+extern void nfs41_handle_server_scope(struct nfs_client *, struct server_scope **);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t, pid_t);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 69c0f3c..455e7f8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4751,6 +4751,16 @@ out_inval:
 	return -NFS4ERR_INVAL;
 }
 
+static bool
+nfs41_same_server_scope(struct server_scope *a, struct server_scope *b)
+{
+	if (a->server_scope_sz == b->server_scope_sz &&
+	    memcmp(a->server_scope, b->server_scope, a->server_scope_sz) == 0)
+		return true;
+
+	return false;
+}
+
 /*
  * nfs4_proc_exchange_id()
  *
@@ -4793,9 +4803,31 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 				init_utsname()->domainname,
 				clp->cl_rpcclient->cl_auth->au_flavor);
 
+	res.server_scope = kzalloc(sizeof(struct server_scope), GFP_KERNEL);
+	if (unlikely(!res.server_scope))
+		return -ENOMEM;
+
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (!status)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
+
+	if (!status) {
+		if (clp->server_scope &&
+		    !nfs41_same_server_scope(clp->server_scope,
+					     res.server_scope)) {
+			dprintk("%s: server_scope mismatch detected\n",
+				__func__);
+			set_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state);
+			kfree(clp->server_scope);
+			clp->server_scope = NULL;
+		}
+
+		if (!clp->server_scope)
+			clp->server_scope = res.server_scope;
+		else
+			kfree(res.server_scope);
+	}
+
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 036f5ad..4138453 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1639,7 +1639,14 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 			}
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
-			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
+
+			if (test_and_clear_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH,
+					       &clp->cl_state))
+				nfs4_state_start_reclaim_nograce(clp);
+			else
+				set_bit(NFS4CLNT_RECLAIM_REBOOT,
+					&clp->cl_state);
+
 			pnfs_destroy_all_layouts(clp);
 		}
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c3ccd2c..09a19ca 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4909,11 +4909,17 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	if (unlikely(status))
 		return status;
 
-	/* Throw away server_scope */
+	/* Save server_scope */
 	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 	if (unlikely(status))
 		return status;
 
+	if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
+		return -EIO;
+
+	memcpy(res->server_scope->server_scope, dummy_str, dummy);
+	res->server_scope->server_scope_sz = dummy;
+
 	/* Throw away Implementation id array */
 	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 	if (unlikely(status))
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 87694ca..f23b188 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -16,6 +16,7 @@ struct nfs4_sequence_args;
 struct nfs4_sequence_res;
 struct nfs_server;
 struct nfs4_minor_version_ops;
+struct server_scope;
 
 /*
  * The nfs_client identifies our client state to the server.
@@ -83,6 +84,8 @@ struct nfs_client {
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
+
+	struct server_scope	*server_scope;	/* from exchange_id */
 };
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 890dce2..31d6df4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1039,6 +1039,7 @@ struct server_scope {
 struct nfs41_exchange_id_res {
 	struct nfs_client		*client;
 	u32				flags;
+	struct server_scope		*server_scope;
 };
 
 struct nfs41_create_session_args {
-- 
1.7.4.2

