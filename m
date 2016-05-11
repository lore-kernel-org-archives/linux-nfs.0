Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:33164 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474AbcEKTI4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 15:08:56 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 08/10] NFS test and add multipaths for session trunking
Date: Wed, 11 May 2016 15:08:23 -0400
Message-ID: <1462993705-14673-9-git-send-email-andros@netapp.com>
In-Reply-To: <1462993705-14673-1-git-send-email-andros@netapp.com>
References: <1462993705-14673-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Test the multipath addresses returned by nfs4_get_pseudofs_replicas
for session trunking.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h           |   7 ++++
 fs/nfs/nfs4proc.c          | 100 ++++++++++++++++++++++++++++++++++++++++++++-
 net/sunrpc/xprtmultipath.c |   3 ++
 3 files changed, 109 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ff8cfcd..e886aa7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -59,6 +59,8 @@ struct nfs4_minor_version_ops {
 			struct nfs4_lock_state *);
 	struct nfs_seqid *
 		(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
+	int	(*session_trunk)(struct rpc_clnt *, struct rpc_xprt_switch *,
+			struct rpc_xprt *, void *);
 	const struct rpc_call_ops *call_sync_ops;
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
@@ -214,6 +216,11 @@ struct nfs4_mig_recovery_ops {
 	int (*fsid_present)(struct inode *, struct rpc_cred *);
 };
 
+struct nfs4_add_xprt_data {
+	struct nfs_client	*clp;
+	struct rpc_cred		*cred;
+};
+
 extern const struct dentry_operations nfs4_dentry_operations;
 
 /* dir.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8263ee8..827ae51 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -44,6 +44,7 @@
 #include <linux/printk.h>
 #include <linux/slab.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
@@ -3303,6 +3304,59 @@ static int nfs4_proc_fs_locations_probe(struct nfs_server *server,
 	return err;
 }
 
+/**
+ * Test the multipath addresses returned by nfs4_get_pseudofs_replicas
+ * for session trunking.
+ *
+ * Add session trunking aliases to the cl_rpcclient
+ */
+void nfs4_test_multipath(struct nfs4_fs_locations *locations,
+			struct nfs_client *clp)
+{
+	struct nfs4_add_xprt_data xprtdata = {
+		.clp = clp,
+	};
+	int i;
+
+	if (!clp->cl_mvops->session_trunk || locations == NULL ||
+	    locations->nlocations <= 0)
+		return;
+
+	xprtdata.cred = nfs4_get_clid_cred(clp);
+
+	for (i = 0; i < locations->nlocations; i++) {
+		struct nfs4_fs_location *loc = &locations->locations[i];
+		int i;
+
+		for (i = 0; i < loc->nservers; i++) {
+			struct nfs4_string *server = &loc->servers[i];
+			struct sockaddr_storage addr;
+			size_t addrlen;
+			struct xprt_create xprt_args = {
+				.ident = XPRT_TRANSPORT_TCP,
+				.net = clp->cl_net,
+			};
+
+			addrlen = rpc_pton(clp->cl_net, server->data,
+					server->len, (struct sockaddr *)&addr,
+					sizeof(addr));
+
+			xprt_args.dstaddr = (struct sockaddr *)&addr;
+			xprt_args.addrlen = addrlen;
+			xprt_args.servername = server->data;
+
+			/**
+			 * Check for session trunking. Add this address as
+			 * an alias if session trunking is permitted.
+			 */
+			rpc_clnt_add_xprt(clp->cl_rpcclient, &xprt_args,
+					clp->cl_mvops->session_trunk,
+					&xprtdata);
+		}
+	}
+	if (xprtdata.cred)
+		put_rpccred(xprtdata.cred);
+}
 
 /**
  * Probe the pseudo filesystem for an fs_locations replicas list.
@@ -3330,7 +3384,8 @@ void nfs4_get_pseudofs_replicas(struct nfs_server *server,
 	if (status != 0)
 		goto out;
 
-	/* test replicas for session trunking here */
+	/* test replicas for session trunking */
+	nfs4_test_multipath(locations, server->nfs_client);
 out:
 	if (page)
 		__free_page(page);
@@ -7291,6 +7346,47 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE, NULL);
 }
 
+/**
+ * nfs4_test_session_trunk - Test for session trunking with a
+ * synchronous exchange_id call. Upon success, add a new transport
+ * to the rpc_clnt
+ *
+ * @clnt: struct rpc_clnt to get new transport
+ * @xps:  the rpc_xprt_switch to hold the new transport
+ * @xprt: the rpc_xprt to test
+ * @data: call data for _nfs4_proc_exchange_id.
+ *
+ */
+int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt_switch *xps,
+			    struct rpc_xprt *xprt, void *data)
+{
+	struct nfs4_add_xprt_data *xdata = (struct nfs4_add_xprt_data *)data;
+	u32 sp4_how;
+	int status;
+
+	sp4_how = (xdata->clp->cl_sp4_flags == 0 ? SP4_NONE : SP4_MACH_CRED);
+
+	/* Ensure these stick around for the rpc call */
+	xps = xprt_switch_get(xps);
+	xprt = xprt_get(xprt);
+
+	/* Sync call */
+	status = _nfs4_proc_exchange_id(xdata->clp, xdata->cred, sp4_how, xprt);
+
+	xprt_put(xprt);
+	xprt_switch_put(xps);
+
+	if (status)
+		pr_info("NFS:   %s: Session trunking failed for %s status %d\n",
+			xdata->clp->cl_hostname,
+			xprt->address_strings[RPC_DISPLAY_ADDR], status);
+	else
+		pr_info("NFS:   %s: Session trunking succeeded for %s\n",
+			xdata->clp->cl_hostname,
+			xprt->address_strings[RPC_DISPLAY_ADDR]);
+	return status;
+}
+
 static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
 		struct rpc_cred *cred)
 {
@@ -8882,6 +8978,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
 	.alloc_seqid = nfs_alloc_no_seqid,
+	.session_trunk = nfs4_test_session_trunk,
 	.call_sync_ops = &nfs41_call_sync_ops,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
@@ -8910,6 +9007,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 	.free_lock_state = nfs41_free_lock_state,
 	.call_sync_ops = &nfs41_call_sync_ops,
 	.alloc_seqid = nfs_alloc_no_seqid,
+	.session_trunk = nfs4_test_session_trunk,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index e7fd769..360f64c 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -53,6 +53,7 @@ void rpc_xprt_switch_add_xprt(struct rpc_xprt_switch *xps,
 		xprt_switch_add_xprt_locked(xps, xprt);
 	spin_unlock(&xps->xps_lock);
 }
+EXPORT_SYMBOL_GPL(rpc_xprt_switch_add_xprt);
 
 static void xprt_switch_remove_xprt_locked(struct rpc_xprt_switch *xps,
 		struct rpc_xprt *xprt)
@@ -145,6 +146,7 @@ struct rpc_xprt_switch *xprt_switch_get(struct rpc_xprt_switch *xps)
 		return xps;
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(xprt_switch_get);
 
 /**
  * xprt_switch_put - Release a reference to a rpc_xprt_switch
@@ -157,6 +159,7 @@ void xprt_switch_put(struct rpc_xprt_switch *xps)
 	if (xps != NULL)
 		kref_put(&xps->xps_kref, xprt_switch_free);
 }
+EXPORT_SYMBOL_GPL(xprt_switch_put);
 
 /**
  * rpc_xprt_switch_set_roundrobin - Set a round-robin policy on rpc_xprt_switch
-- 
1.8.3.1

