Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:8559 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670AbcD0PqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:46:16 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 8/9] NFS test and add multi-addrs for session trunking
Date: Wed, 27 Apr 2016 11:36:09 -0400
Message-ID: <1461771370-16375-9-git-send-email-andros@netapp.com>
In-Reply-To: <1461771370-16375-1-git-send-email-andros@netapp.com>
References: <1461771370-16375-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h           |  5 +++++
 fs/nfs/nfs4client.c        | 39 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c          | 37 +++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtmultipath.c |  3 +++
 4 files changed, 84 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4c21022..f496526 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -218,6 +218,11 @@ struct nfs4_add_xprt_data {
 	struct nfs_client	*clp;
 	struct rpc_cred		*cred;
 };
+extern int nfs4_test_session_trunk_and_add_xprt(struct rpc_clnt *clnt,
+						struct rpc_xprt_switch *xps,
+						struct rpc_xprt *xprt,
+						void *data);
+
 extern const struct dentry_operations nfs4_dentry_operations;
 
 /* dir.c */
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2121c1f..c5cbf89 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1041,6 +1041,43 @@ out:
 	return error;
 }
 
+/**
+ * Add rpc_xprts to an existing RPC client
+ */
+void nfs4_try_multiaddr(struct nfs_parsed_mount_data *mnt,
+			struct nfs_client *clp)
+{
+	struct multi_addr *multip = mnt->multiaddrs;
+	struct nfs4_add_xprt_data xprtdata = {
+		.clp = clp,
+	};
+	int i;
+
+	dprintk("NFS:   Try adding %u multi addrs\n", mnt->num_multi);
+
+	if (mnt->num_multi == 0)
+		return;
+
+	xprtdata.cred = nfs4_get_clid_cred(clp);
+
+	for (i = 0; i < mnt->num_multi; i++) {
+		struct xprt_create xprt_args = {
+			.ident = XPRT_TRANSPORT_TCP,
+			.net = mnt->net,
+			.dstaddr = (struct sockaddr *)&multip->addr,
+			.addrlen = multip->addrlen,
+			.servername = multip->hostname,
+		};
+		/* Add this address as an alias */
+		rpc_clnt_add_xprt(clp->cl_rpcclient, &xprt_args,
+				  nfs4_test_session_trunk_and_add_xprt,
+				  &xprtdata);
+		multip++;
+	}
+	if (xprtdata.cred)
+		put_rpccred(xprtdata.cred);
+}
+
 /*
  * Create a version 4 volume record
  */
@@ -1097,6 +1134,8 @@ static int nfs4_init_server(struct nfs_server *server,
 	error = nfs_init_server_rpcclient(server, &timeparms,
 					  data->selected_flavor);
 
+	if (!error)
+		nfs4_try_multiaddr(data, server->nfs_client);
 error:
 	/* Done */
 	dprintk("<-- nfs4_init_server() = %d\n", error);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 70537f0..934c668 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7207,6 +7207,43 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	return _nfs4_proc_exchange_id(clp, cred, SP4_NONE, NULL);
 }
 
+/**
+ * nfs4_test_session_trunk_and_add_xprt - Test for session trunking with a
+ * synchronous exchange_id call, and add a new transport to the rpc_clnt
+ *
+ * @clnt: struct rpc_clnt to get new transport
+ * @xps:  the rpc_xprt_switch to hold the new transport
+ * @xprt: the rpc_xprt to test
+ * @data: call data for _nfs4_proc_exchange_id.
+ *
+ */
+int nfs4_test_session_trunk_and_add_xprt(struct rpc_clnt *clnt,
+					struct rpc_xprt_switch *xps,
+					struct rpc_xprt *xprt,
+					void *data)
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
+		pr_info("NFS: mulitaddr %s establishment failed. status %d\n",
+			xprt->address_strings[RPC_DISPLAY_ADDR], status);
+	return status;
+}
+
 static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
 		struct rpc_cred *cred)
 {
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

