Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f52.google.com ([209.85.213.52]:42392 "EHLO
	mail-yw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab2GKUbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:31:37 -0400
Received: by yhpp61 with SMTP id p61so1950645yhp.11
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:31:36 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/15] NFS: Discover NFSv4 server trunking when mounting
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:31:34 -0400
Message-ID: <20120711203134.3767.47961.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Server trunking" is a fancy named for a multi-homed NFS server.
Trunking might occur if a client sends NFS requests for a single
workload to multiple network interfaces on the same server.  There
are some implications for NFSv4 state management that make it useful
for a client to know if a single NFSv4 server instance is
multi-homed.  (Note this is only a consideration for NFSv4, not for
legacy versions of NFS, which are stateless).

If a client cares about server trunking, no NFSv4 operations can
proceed until that client determines who it is talking to.  Thus
server IP trunking discovery must be done when the client first
encounters an unfamiliar server IP address.

The nfs_get_client() function walks the nfs_client_list and matches
on server IP address.  The outcome of that walk tells us immediately
if we have an unfamiliar server IP address.  It invokes
nfs_init_client() in this case.  Thus, nfs4_init_client() is a good
spot to perform trunking discovery.

Discovery requires a client to establish a fresh client ID, so our
client will now send SETCLIENTID or EXCHANGE_ID as the first NFS
operation after a successful ping, rather than waiting for an
application to perform an operation that requires NFSv4 state.

The exact process for detecting trunking is different for NFSv4.0 and
NFSv4.1, so a minorversion-specific init_client callout method is
introduced.

CLID_INUSE recovery is important for the trunking discovery process.
CLID_INUSE is a sign the server recognizes the client's nfs_client_id4
id string, but the client is using the wrong principal this time for
the SETCLIENTID operation.  The SETCLIENTID must be retried with a
series of different principals until one works, and the rest of
trunking discovery can proceed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c    |  237 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/internal.h  |    6 +
 fs/nfs/nfs4_fs.h   |    8 ++
 fs/nfs/nfs4proc.c  |    2 
 fs/nfs/nfs4state.c |  186 ++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 433 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5bad694..ea1e423 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -576,7 +576,8 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 			return nfs_found_client(cl_init, clp);
 		}
 		if (new) {
-			list_add(&new->cl_share_link, &nn->nfs_client_list);
+			list_add_tail(&new->cl_share_link,
+					&nn->nfs_client_list);
 			spin_unlock(&nn->nfs_client_lock);
 			new->cl_flags = cl_init->init_flags;
 			return cl_init->rpc_ops->init_client(new,
@@ -594,6 +595,228 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	return new;
 }
 
+#ifdef CONFIG_NFS_V4
+/*
+ * Returns true if the client IDs match
+ */
+static bool nfs4_match_clientids(struct nfs_client *a, struct nfs_client *b)
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
+/*
+ * SETCLIENTID just did a callback update with the callback ident in
+ * "drop," but server trunking discovery claims "drop" and "keep" are
+ * actually the same server.  Swap the callback IDs so that "keep"
+ * will continue to use the callback ident the server now knows about,
+ * and so that "keep"'s original callback ident is destroyed when
+ * "drop" is freed.
+ */
+static void nfs4_swap_callback_idents(struct nfs_client *keep,
+				      struct nfs_client *drop)
+{
+	struct nfs_net *nn = net_generic(keep->cl_net, nfs_net_id);
+	unsigned int save = keep->cl_cb_ident;
+
+	if (keep->cl_cb_ident == drop->cl_cb_ident)
+		return;
+
+	dprintk("%s: keeping callback ident %u and dropping ident %u\n",
+		__func__, keep->cl_cb_ident, drop->cl_cb_ident);
+
+	spin_lock(&nn->nfs_client_lock);
+
+	idr_replace(&nn->cb_ident_idr, keep, drop->cl_cb_ident);
+	keep->cl_cb_ident = drop->cl_cb_ident;
+
+	idr_replace(&nn->cb_ident_idr, drop, save);
+	drop->cl_cb_ident = save;
+
+	spin_unlock(&nn->nfs_client_lock);
+}
+
+/**
+ * nfs40_walk_client_list - Find server that recognizes a client ID
+ *
+ * @new: nfs_client with client ID to test
+ * @result: OUT: found nfs_client, or new
+ * @cred: credential to use for trunking test
+ *
+ * Returns zero, a negative errno, or a negative NFS4ERR status.
+ * If zero is returned, an nfs_client pointer is planted in "result."
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
+		if (pos->cl_clientid != new->cl_clientid)
+			continue;
+
+		atomic_inc(&pos->cl_count);
+		spin_unlock(&nn->nfs_client_lock);
+
+		if (prev)
+			nfs_put_client(prev);
+
+		status = nfs4_proc_setclientid_confirm(pos, &clid, cred);
+		if (status == 0) {
+			nfs4_swap_callback_idents(pos, new);
+
+			nfs_put_client(pos);
+			*result = pos;
+			dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+				__func__, pos, atomic_read(&pos->cl_count));
+			return 0;
+		}
+		if (status != -NFS4ERR_STALE_CLIENTID) {
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
+	pr_err("NFS: %s Error: no matching nfs_client found\n", __func__);
+	return -NFS4ERR_STALE_CLIENTID;
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
+ * Returns zero, a negative errno, or a negative NFS4ERR status.
+ * If zero is returned, an nfs_client pointer is planted in "result."
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
+		spin_unlock(&nn->nfs_client_lock);
+		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+			__func__, pos, atomic_read(&pos->cl_count));
+
+		*result = pos;
+		return 0;
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
+	pr_err("NFS: %s Error: no matching nfs_client found\n", __func__);
+	return -NFS4ERR_STALE_CLIENTID;
+}
+#endif	/* CONFIG_NFS_V4_1 */
+#endif	/* CONFIG_NFS_V4 */
+
 /*
  * Mark a server as ready or failed
  */
@@ -1369,6 +1592,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				    rpc_authflavor_t authflavour)
 {
 	char buf[INET6_ADDRSTRLEN + 1];
+	struct nfs_client *old;
 	int error;
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
@@ -1414,6 +1638,17 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 
 	if (!nfs4_has_session(clp))
 		nfs_mark_client_ready(clp, NFS_CS_READY);
+
+	error = nfs4_discover_server_trunking(clp, &old);
+	if (error < 0)
+		goto error;
+	if (clp != old) {
+		nfs_mark_client_ready(clp, NFS_CS_READY);
+		nfs_put_client(clp);
+		clp = old;
+		atomic_inc(&clp->cl_count);
+	}
+
 	return clp;
 
 error:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 92d1a5e..305a549 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -155,6 +155,12 @@ extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
 				struct nfs4_sessionid *);
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
index cc5900a..2df6668 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -191,6 +191,8 @@ struct nfs4_state_recovery_ops {
 	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
 	struct rpc_cred * (*get_clid_cred)(struct nfs_client *);
 	int (*reclaim_complete)(struct nfs_client *);
+	int (*detect_trunking)(struct nfs_client *, struct nfs_client **,
+		struct rpc_cred *);
 };
 
 struct nfs4_state_maintenance_ops {
@@ -310,9 +312,15 @@ extern void nfs4_renew_state(struct work_struct *);
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
+int nfs4_discover_server_trunking(struct nfs_client *clp,
+			struct nfs_client **);
+int nfs40_discover_server_trunking(struct nfs_client *clp,
+			struct nfs_client **, struct rpc_cred *);
 #if defined(CONFIG_NFS_V4_1)
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
+int nfs41_discover_server_trunking(struct nfs_client *clp,
+			struct nfs_client **, struct rpc_cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
 #else
 static inline void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b09b849..bb46ed1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6794,6 +6794,7 @@ static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.recover_lock	= nfs4_lock_reclaim,
 	.establish_clid = nfs4_init_clientid,
 	.get_clid_cred	= nfs4_get_setclientid_cred,
+	.detect_trunking = nfs40_discover_server_trunking,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -6805,6 +6806,7 @@ static const struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.establish_clid = nfs41_init_clientid,
 	.get_clid_cred	= nfs4_get_exchange_id_cred,
 	.reclaim_complete = nfs41_proc_reclaim_complete,
+	.detect_trunking = nfs41_discover_server_trunking,
 };
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0d4c0c6..5e3bebc 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -51,6 +51,8 @@
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
 
+#include <linux/sunrpc/clnt.h>
+
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
@@ -62,7 +64,7 @@
 #define OPENOWNER_POOL_SIZE	8
 
 const nfs4_stateid zero_stateid;
-
+static DEFINE_MUTEX(nfs_clid_init_mutex);
 static LIST_HEAD(nfs4_clientid_list);
 
 int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
@@ -96,6 +98,52 @@ out:
 	return status;
 }
 
+/**
+ * nfs40_discover_server_trunking - Detect server IP address trunking (mv0)
+ *
+ * @clp: nfs_client under test
+ * @result: OUT: found nfs_client, or clp
+ * @cred: credential to use for trunking test
+ *
+ * Returns zero, a negative errno, or a negative NFS4ERR status.
+ * If zero is returned, an nfs_client pointer is planted in
+ * "result".
+ */
+int nfs40_discover_server_trunking(struct nfs_client *clp,
+				   struct nfs_client **result,
+				   struct rpc_cred *cred)
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
+	if (status != 0)
+		goto out;
+	clp->cl_clientid = clid.clientid;
+	clp->cl_confirm = clid.confirm;
+
+	status = nfs40_walk_client_list(clp, result, cred);
+	if (status == -NFS4ERR_STALE_CLIENTID)
+		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+
+	/*
+	 * Sustain the lease, even if it's empty.  If the clientid4
+	 * goes stale it's of no use for trunking discovery.
+	 */
+	nfs4_schedule_state_renewal(*result);
+
+out:
+	return status;
+}
+
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = NULL;
@@ -275,6 +323,46 @@ out:
 	return status;
 }
 
+/**
+ * nfs41_discover_server_trunking - Detect server IP address trunking (mv1)
+ *
+ * @clp: nfs_client under test
+ * @result: OUT: found nfs_client, or clp
+ * @cred: credential to use for trunking test
+ *
+ * Returns NFS4_OK, a negative errno, or a negative NFS4ERR status.
+ * If NFS4_OK is returned, an nfs_client pointer is planted in
+ * "result".
+ */
+int nfs41_discover_server_trunking(struct nfs_client *clp,
+				   struct nfs_client **result,
+				   struct rpc_cred *cred)
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
+	status = nfs4_proc_create_session(trunked, cred);
+	if (status != NFS4_OK)
+		goto out;
+	clear_bit(NFS4CLNT_LEASE_CONFIRM, &trunked->cl_state);
+	nfs41_setup_state_renewal(trunked);
+	nfs_mark_client_ready(trunked, NFS_CS_READY);
+	*result = trunked;
+out:
+	nfs4_end_drain_session(clp);
+	return status;
+}
+
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;
@@ -1656,16 +1744,104 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 	struct rpc_cred *cred;
 	const struct nfs4_state_recovery_ops *ops =
 		clp->cl_mvops->reboot_recovery_ops;
-	int status;
+	int status = -ENOENT;
 
+	mutex_lock(&nfs_clid_init_mutex);
 	cred = ops->get_clid_cred(clp);
 	if (cred == NULL)
-		return -ENOENT;
+		goto out;
 	status = ops->establish_clid(clp, cred);
 	put_rpccred(cred);
 	if (status != 0)
-		return nfs4_handle_reclaim_lease_error(clp, status);
-	return 0;
+		status = nfs4_handle_reclaim_lease_error(clp, status);
+out:
+	mutex_unlock(&nfs_clid_init_mutex);
+	return status;
+}
+
+/**
+ * nfs4_discover_server_trunking - Detect server IP address trunking
+ *
+ * @clp: nfs_client under test
+ * @result: OUT: found nfs_client, or clp
+ *
+ * Returns zero or a negative errno.  If zero is returned,
+ * an nfs_client pointer is planted in "result".
+ *
+ * Note: since we are invoked in process context, and
+ * not from inside the state manager, we cannot use
+ * nfs4_handle_reclaim_lease_error().
+ */
+int nfs4_discover_server_trunking(struct nfs_client *clp,
+				  struct nfs_client **result)
+{
+	const struct nfs4_state_recovery_ops *ops =
+				clp->cl_mvops->reboot_recovery_ops;
+	rpc_authflavor_t flav, flavors[NFS_MAX_SECFLAVORS];
+	struct rpc_auth *auth;
+	struct rpc_cred *cred;
+	int i, len, status;
+
+	dprintk("NFS: %s: testing '%s'\n", __func__, clp->cl_hostname);
+	mutex_lock(&nfs_clid_init_mutex);
+
+	i = 0;
+	len = rpcauth_list_flavors(flavors, ARRAY_SIZE(flavors));
+
+	status  = -ENOENT;
+again:
+	cred = ops->get_clid_cred(clp);
+	if (cred == NULL)
+		goto out;
+
+	status = ops->detect_trunking(clp, result, cred);
+	put_rpccred(cred);
+	switch (status) {
+	case 0:
+		break;
+
+	case -EACCES:
+		if (clp->cl_machine_cred == NULL)
+			break;
+		/* Handle case where the user hasn't set up machine creds */
+		nfs4_clear_machine_cred(clp);
+	case -NFS4ERR_DELAY:
+	case -ETIMEDOUT:
+	case -EAGAIN:
+		ssleep(1);
+		dprintk("NFS: %s after status %d, retrying\n",
+			__func__, status);
+		goto again;
+
+	case -NFS4ERR_CLID_INUSE:
+	case -NFS4ERR_WRONGSEC:
+		status = -EPERM;
+		if (i >= len)
+			break;
+
+		flav = flavors[i++];
+		auth = rpcauth_create(flav, clp->cl_rpcclient);
+		if (IS_ERR(auth)) {
+			status = PTR_ERR(auth);
+			break;
+		}
+		goto again;
+
+	case -NFS4ERR_MINOR_VERS_MISMATCH:
+		status = -EPROTONOSUPPORT;
+		break;
+
+	case -EKEYEXPIRED:
+		nfs4_warn_keyexpired(clp->cl_hostname);
+	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
+				 * in nfs4_exchange_id */
+		status = -EKEYEXPIRED;
+	}
+
+out:
+	mutex_unlock(&nfs_clid_init_mutex);
+	dprintk("NFS: %s: status = %d\n", __func__, status);
+	return status;
 }
 
 #ifdef CONFIG_NFS_V4_1

