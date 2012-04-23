Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab2DWUzz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:55:55 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:55:55 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/20] NFS: Detect NFSv4 server trunking when mounting
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:55:53 -0400
Message-ID: <20120423205552.11446.58714.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the Linux NFS client waits to perform a SETCLIENTID until
just before an application wants to open a file.  Quite a bit of
activity can occur before any state is needed.

If the client cares about server trunking, however, no NFSv4
operations can proceed until the client determines who it is talking
to.  Thus server IP trunking detection must be done when the client
first encounters an unfamiliar server IP address.

The nfs_get_client() function walks the nfs_client_list and matches on
server IP address.  The outcome of that walk tells us immediately if
we have an unfamiliar server IP address.  It invokes an init_client()
method in this case.

Thus, nfs4_init_client() can establish a fresh client ID, and perform
trunking detection with it.  The exact process for detecting trunking
is different for NFSv4.0 and NFSv4.1, so a minorversion-specific
init_client callout is introduced.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c    |  223 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/internal.h  |    6 +
 fs/nfs/nfs4_fs.h   |    7 ++
 fs/nfs/nfs4proc.c  |    2 
 fs/nfs/nfs4state.c |  131 ++++++++++++++++++++++++++++++-
 5 files changed, 367 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 920abbc..7330673 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -566,7 +566,8 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 			return nfs_found_client(cl_init, clp);
 		}
 		if (new) {
-			list_add(&new->cl_share_link, &nn->nfs_client_list);
+			list_add_tail(&new->cl_share_link,
+					&nn->nfs_client_list);
 			spin_unlock(&nn->nfs_client_lock);
 			new->cl_flags = cl_init->init_flags;
 			return cl_init->rpc_ops->init_client(new,
@@ -584,6 +585,210 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	return new;
 }
 
+#ifdef CONFIG_NFS_V4
+/*
+ * Returns true if the client IDs match
+ */
+static bool
+nfs4_match_clientids(struct nfs_client *a, struct nfs_client *b)
+{
+	if (a->cl_clientid != b->cl_clientid) {
+		dprintk("NFS: --> %s client ID %llx does not match %llx\n",
+			__func__, a->cl_clientid, b->cl_clientid);
+		return false;
+	}
+	dprintk("NFS: --> %s client ID %llx matches %llx\n",
+		__func__, a->cl_clientid, b->cl_clientid);
+	return true;
+}
+
+/**
+ * nfs40_walk_client_list - Find server that recognizes a client ID
+ *
+ * @new: nfs_client with client ID to test
+ * @result: OUT: found nfs_client, or new
+ * @cred: credential to use for trunking test
+ *
+ * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
+ * If NFS4_OK is returned, an nfs_client pointer is planted in "result."
+ *
+ * NB: nfs40_walk_client_list() relies on the new nfs_client being
+ *     the last nfs_client on the list.
+ */
+int nfs40_walk_client_list(struct nfs_client *new,
+			   struct nfs_client **result,
+			   struct rpc_cred *cred)
+{
+	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
+	struct nfs_client *pos, *prev = NULL;
+	struct nfs4_setclientid_res clid = {
+		.clientid	= new->cl_clientid,
+		.confirm	= new->cl_confirm,
+	};
+	int status;
+
+	dprintk("NFS: --> %s nfs_client = %p\n", __func__, new);
+
+	spin_lock(&nn->nfs_client_lock);
+
+	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
+		if (pos->cl_cons_state < 0)
+			continue;
+
+		if (pos->rpc_ops != new->rpc_ops)
+			continue;
+
+		if (pos->cl_proto != new->cl_proto)
+			continue;
+
+		if (pos->cl_minorversion != new->cl_minorversion)
+			continue;
+
+		dprintk("NFS: --> %s comparing %llx and %llx\n", __func__,
+			new->cl_clientid, pos->cl_clientid);
+		if (pos->cl_clientid != new->cl_clientid)
+			continue;
+
+		atomic_inc(&pos->cl_count);
+		dprintk("%s nfs_client = %p ({%d})\n",
+			__func__, pos, atomic_read(&pos->cl_count));
+		spin_unlock(&nn->nfs_client_lock);
+
+		dprintk("NFS: --> %s confirming %llx\n",
+			__func__, new->cl_clientid);
+
+		if (prev)
+			nfs_put_client(prev);
+
+		status = nfs4_proc_setclientid_confirm(pos, &clid, cred);
+		if (status == NFS4_OK) {
+			/* The new nfs_client doesn't need the extra
+			 * cl_count bump. */
+			nfs_put_client(pos);
+			*result = pos;
+			dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+				__func__, pos, atomic_read(&pos->cl_count));
+			return NFS4_OK;
+		}
+		if (status != NFS4ERR_STALE_CLIENTID) {
+			nfs_put_client(pos);
+			dprintk("NFS: <-- %s status = %d, no result\n",
+				__func__, status);
+			return status;
+		}
+
+		spin_lock(&nn->nfs_client_lock);
+		prev = pos;
+	}
+
+	/*
+	 * No matching nfs_client found.  This should be impossible,
+	 * because the new nfs_client has already been added to
+	 * nfs_client_list by nfs_get_client().
+	 *
+	 * Don't BUG(), since the caller is holding a mutex.
+	 */
+	spin_unlock(&nn->nfs_client_lock);
+	printk(KERN_ERR "NFS: %s Error: no matching nfs_client found\n",
+		__func__);
+	return NFS4ERR_STALE_CLIENTID;
+}
+
+#ifdef CONFIG_NFS_V4_1
+/*
+ * Returns true if the server owners match
+ */
+static bool
+nfs4_match_serverowners(struct nfs_client *a, struct nfs_client *b)
+{
+	struct nfs41_server_owner *o1 = a->cl_serverowner;
+	struct nfs41_server_owner *o2 = b->cl_serverowner;
+
+	if (o1->minor_id != o2->minor_id) {
+		dprintk("NFS: --> %s server owner minor IDs do not match\n",
+			__func__);
+		return false;
+	}
+
+	if (o1->major_id_sz != o2->major_id_sz)
+		goto out_major_mismatch;
+	if (memcmp(o1->major_id, o2->major_id, o1->major_id_sz) != 0)
+		goto out_major_mismatch;
+
+	dprintk("NFS: --> %s server owners match\n", __func__);
+	return true;
+
+out_major_mismatch:
+	dprintk("NFS: --> %s server owner major IDs do not match\n",
+		__func__);
+	return false;
+}
+
+/**
+ * nfs41_walk_client_list - Find nfs_client that matches a client/server owner
+ *
+ * @new: nfs_client with client ID to test
+ * @result: OUT: found nfs_client, or new
+ * @cred: credential to use for trunking test
+ *
+ * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
+ * If NFS4_OK is returned, an nfs_client pointer is planted in "result."
+ *
+ * NB: nfs41_walk_client_list() relies on the new nfs_client being
+ *     the last nfs_client on the list.
+ */
+int nfs41_walk_client_list(struct nfs_client *new,
+			   struct nfs_client **result,
+			   struct rpc_cred *cred)
+{
+	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
+	struct nfs_client *pos;
+
+	dprintk("NFS: --> %s nfs_client = %p\n", __func__, new);
+
+	spin_lock(&nn->nfs_client_lock);
+
+	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
+		if (pos->cl_cons_state < 0)
+			continue;
+
+		if (pos->rpc_ops != new->rpc_ops)
+			continue;
+
+		if (pos->cl_proto != new->cl_proto)
+			continue;
+
+		if (pos->cl_minorversion != new->cl_minorversion)
+			continue;
+
+		if (!nfs4_match_clientids(pos, new))
+			continue;
+
+		if (!nfs4_match_serverowners(pos, new))
+			continue;
+
+		atomic_inc(&pos->cl_count);
+		*result = pos;
+		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+			__func__, pos, atomic_read(&pos->cl_count));
+		return NFS4_OK;
+	}
+
+	/*
+	 * No matching nfs_client found.  This should be impossible,
+	 * because the new nfs_client has already been added to
+	 * nfs_client_list by nfs_get_client().
+	 *
+	 * Don't BUG(), since the caller is holding a mutex.
+	 */
+	spin_unlock(&nn->nfs_client_lock);
+	printk(KERN_ERR "NFS: %s Error: no matching nfs_client found\n",
+		__func__);
+	return NFS4ERR_STALE_CLIENTID;
+}
+#endif	/* CONFIG_NFS_V4_1 */
+#endif	/* CONFIG_NFS_V4 */
+
 /*
  * Mark a server as ready or failed
  */
@@ -1350,6 +1555,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				    rpc_authflavor_t authflavour)
 {
 	char buf[INET6_ADDRSTRLEN + 1];
+	struct nfs_client *old;
 	int error;
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
@@ -1395,6 +1601,21 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 
 	if (!nfs4_has_session(clp))
 		nfs_mark_client_ready(clp, NFS_CS_READY);
+
+	error = nfs4_detect_trunking(clp, &old);
+	if (error < 0)
+		goto error;
+	if (clp != old) {
+		nfs_mark_client_ready(clp, NFS_CS_READY);
+		nfs_put_client(clp);
+		dprintk("<-- %s() returning %p instead of %p\n",
+			__func__, old, clp);
+		clp = old;
+		atomic_inc(&clp->cl_count);
+		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
+	}
+
 	return clp;
 
 error:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 315dc86..85888f6 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -162,6 +162,12 @@ extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				const struct rpc_timeout *timeparms,
 				const char *ip_addr,
 				rpc_authflavor_t authflavour);
+extern int nfs40_walk_client_list(struct nfs_client *clp,
+				struct nfs_client **result,
+				struct rpc_cred *cred);
+extern int nfs41_walk_client_list(struct nfs_client *clp,
+				struct nfs_client **result,
+				struct rpc_cred *cred);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 2953f2c..ba13986 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -190,6 +190,8 @@ struct nfs4_state_recovery_ops {
 	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
 	struct rpc_cred * (*get_clid_cred)(struct nfs_client *);
 	int (*reclaim_complete)(struct nfs_client *);
+	int (*detect_trunking)(struct nfs_client *, struct nfs_client **,
+		struct rpc_cred *);
 };
 
 struct nfs4_state_maintenance_ops {
@@ -297,9 +299,14 @@ extern void nfs4_renew_state(struct work_struct *);
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
+int nfs4_detect_trunking(struct nfs_client *clp, struct nfs_client **);
+int nfs40_detect_trunking(struct nfs_client *clp, struct nfs_client **,
+			struct rpc_cred *);
 #if defined(CONFIG_NFS_V4_1)
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
+int nfs41_detect_trunking(struct nfs_client *clp, struct nfs_client **,
+			struct rpc_cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *);
 #else
 static inline void nfs4_schedule_session_recovery(struct nfs4_session *session)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3fd9944..00b5d02 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6453,6 +6453,7 @@ static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs4_init_clientid,
 	.get_clid_cred	= nfs4_get_setclientid_cred,
+	.detect_trunking = nfs40_detect_trunking,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -6464,6 +6465,7 @@ static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.establish_clid = nfs41_init_clientid,
 	.get_clid_cred	= nfs4_get_exchange_id_cred,
 	.reclaim_complete = nfs41_proc_reclaim_complete,
+	.detect_trunking = nfs41_detect_trunking,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6a1a305..df59951 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -57,10 +57,12 @@
 #include "internal.h"
 #include "pnfs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
 #define OPENOWNER_POOL_SIZE	8
 
 const nfs4_stateid zero_stateid;
-
+static DEFINE_MUTEX(nfs_clid_init_mutex);
 static LIST_HEAD(nfs4_clientid_list);
 
 int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
@@ -94,6 +96,47 @@ out:
 	return status;
 }
 
+/**
+ * nfs40_detect_trunking - Detect server IP address trunking (mv0)
+ *
+ * @clp: nfs_client under test
+ * @result: OUT: found nfs_client, or clp
+ * @cred: credential to use for trunking test
+ *
+ * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
+ * If NFS4_OK is returned, an nfs_client pointer is planted in
+ * "result".
+ */
+int nfs40_detect_trunking(struct nfs_client *clp, struct nfs_client **result,
+			  struct rpc_cred *cred)
+{
+	struct nfs4_setclientid_res clid = {
+		.clientid = clp->cl_clientid,
+		.confirm = clp->cl_confirm,
+	};
+	unsigned short port;
+	int status;
+
+	port = nfs_callback_tcpport;
+	if (clp->cl_addr.ss_family == AF_INET6)
+		port = nfs_callback_tcpport6;
+
+	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
+	if (status != NFS4_OK)
+		goto out;
+	clp->cl_clientid = clid.clientid;
+	clp->cl_confirm = clid.confirm;
+
+	status = nfs40_walk_client_list(clp, result, cred);
+	if (status != NFS4_OK) {
+		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+		nfs4_schedule_state_renewal(*result);
+	}
+
+out:
+	return status;
+}
+
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = NULL;
@@ -264,6 +307,44 @@ out:
 	return status;
 }
 
+/**
+ * nfs41_detect_trunking - Detect server IP address trunking (mv1)
+ *
+ * @clp: nfs_client under test
+ * @result: OUT: found nfs_client, or clp
+ * @cred: credential to use for trunking test
+ *
+ * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
+ * If NFS4_OK is returned, an nfs_client pointer is planted in
+ * "result".
+ */
+int nfs41_detect_trunking(struct nfs_client *clp, struct nfs_client **result,
+			  struct rpc_cred *cred)
+{
+	struct nfs_client *trunked;
+	int status;
+
+	nfs4_begin_drain_session(clp);
+	status = nfs4_proc_exchange_id(clp, cred);
+	if (status != NFS4_OK)
+		goto out;
+
+	status = nfs41_walk_client_list(clp, &trunked, cred);
+	if (status != NFS4_OK)
+		goto out;
+
+	set_bit(NFS4CLNT_LEASE_CONFIRM, &trunked->cl_state);
+	status = nfs4_proc_create_session(trunked);
+	if (status != NFS4_OK)
+		goto out;
+	clear_bit(NFS4CLNT_LEASE_CONFIRM, &trunked->cl_state);
+	nfs41_setup_state_renewal(trunked);
+	nfs_mark_client_ready(trunked, NFS_CS_READY);
+	*result = trunked;
+out:
+	return status;
+}
+
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
@@ -1579,6 +1660,8 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 	rpc_authflavor_t flavors[NFS_MAX_SECFLAVORS];
 	int i, len, status;
 
+	mutex_lock(&nfs_clid_init_mutex);
+
 	i = 0;
 	len = gss_mech_list_pseudoflavors(flavors);
 
@@ -1613,6 +1696,52 @@ again:
 			break;
 		}
 	}
+
+	mutex_unlock(&nfs_clid_init_mutex);
+	return status;
+}
+
+/**
+ * nfs4_detect_trunking - Detect server IP address trunking
+ *
+ * @clp: nfs_client under test
+ * @result: OUT: found nfs_client, or clp
+ *
+ * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
+ * If NFS4_OK is returned, an nfs_client pointer is planted in
+ * "result".
+ */
+int nfs4_detect_trunking(struct nfs_client *clp,
+			 struct nfs_client **result)
+{
+	const struct nfs4_state_recovery_ops *ops =
+				clp->cl_mvops->reboot_recovery_ops;
+	struct rpc_cred *cred;
+	int status;
+
+	dprintk("NFS: <-- %s nfs_client = %p\n", __func__, clp);
+	mutex_lock(&nfs_clid_init_mutex);
+
+	status = -ENOENT;
+	cred = ops->get_clid_cred(clp);
+	if (cred != NULL) {
+		status = ops->detect_trunking(clp, result, cred);
+		put_rpccred(cred);
+		/* Handle case where the user hasn't set up machine creds */
+		if (status == -EACCES && cred == clp->cl_machine_cred) {
+			nfs4_clear_machine_cred(clp);
+			status = -EAGAIN;
+		}
+		if (status == -NFS4ERR_MINOR_VERS_MISMATCH)
+			status = -EPROTONOSUPPORT;
+	}
+
+	mutex_unlock(&nfs_clid_init_mutex);
+	if (status == NFS4_OK) {
+		clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		dprintk("NFS: <-- %s result = %p\n", __func__, *result);
+	} else
+		dprintk("NFS: <-- %s status = %d\n", __func__, status);
 	return status;
 }
 

