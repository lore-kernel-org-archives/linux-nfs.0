Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e6.ny.us.ibm.com ([32.97.182.146]:47507 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270Ab2A3Tah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 14:30:37 -0500
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 14:30:34 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3E5DA6E805F
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:30:00 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJU0e2254566
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:30:00 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTxrc015803
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 17:29:59 -0200
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTvq2015727
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 17:29:57 -0200
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/13] NFS: Add replace transport infrastructure for replication
Date: Mon, 30 Jan 2012 13:29:52 -0600
Message-Id: <1327951795-16400-11-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adds nfs4_replace_transport() that goes through next replicated server
from the stored replication locations. It replaces the transport.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs4_fs.h          |    1 +
 fs/nfs/nfs4namespace.c    |  125 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 127 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7ff0177..b2a973b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -331,6 +331,7 @@ extern void nfs4_close_state(struct nfs4_state *, fmode_t);
 extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
+int nfs4_replace_transport(struct nfs_server *server);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index bb80c49..ee75e27 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -263,3 +263,128 @@ out:
 	dprintk("%s: done\n", __func__);
 	return mnt;
 }
+
+/*
+ * Returns zero on success, or a negative errno value.
+ */
+static int nfs4_update_server(struct nfs_server *server, const char *hostname,
+			      struct sockaddr *sap, size_t salen)
+{
+	struct nfs_client *clp = server->nfs_client;
+	struct rpc_clnt *clnt = server->client;
+	struct xprt_create xargs = {
+		.ident		= clp->cl_proto,
+		.net		= &init_net,
+		.dstaddr	= sap,
+		.addrlen	= salen,
+		.servername	= hostname,
+	};
+	char buf[INET6_ADDRSTRLEN + 1];
+	struct sockaddr_storage address;
+	struct sockaddr *localaddr = (struct sockaddr *)&address;
+	int error;
+
+	dprintk("--> %s: move FSID %llx:%llx to \"%s\")\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor,
+			hostname);
+
+	/*
+	 * rpc_lock_client() deadlocks here.  This is because the tasks
+	 * that received NFS4ERR_MOVED are waiting for us to wake them
+	 * when we are done recovering.  But they have bumped
+	 * cl_active_tasks for this clnt, so rpc_lock_client() can't make
+	 * any progress.
+	 */
+#ifdef USE_RPC_LOCK_CLIENT
+	error = rpc_lock_client(clnt, clnt->cl_timeout->to_maxval);
+	if (error != 0) {
+		dprintk("<-- %s(): rpc_lock_client returned %d\n",
+			__func__, error);
+		goto out;
+	}
+#endif	/* USE_RPC_LOCK_CLIENT */
+
+	error = rpc_switch_client_transport(clnt, &xargs, clnt->cl_timeout);
+	if (error != 0) {
+		dprintk("<-- %s(): rpc_switch_client_transport returned %d\n",
+			__func__, error);
+		goto out;
+	}
+
+	/*
+	 * If we were able to contact the server at @sap, set up a new
+	 * nfs_client and move @server to it.
+	 */
+	error = rpc_localaddr(clnt, localaddr, sizeof(address));
+	if (error != 0) {
+		dprintk("<-- %s(): rpc_localaddr returned %d\n",
+			__func__, error);
+		goto out;
+	}
+	error = -EAFNOSUPPORT;
+	if (rpc_ntop(localaddr, buf, sizeof(buf)) == 0) {
+		dprintk("<-- %s(): rpc_ntop returned %d\n",
+			__func__, error);
+		goto out;
+	}
+	error = nfs4_clone_client(clp, sap, salen, buf, server);
+	if (error != 0) {
+		dprintk("<-- %s(): nfs4_clone_client returned %d\n",
+			__func__, error);
+		goto out;
+	}
+	if (server->nfs_client->cl_hostname == NULL)
+		server->nfs_client->cl_hostname = kstrdup(hostname, GFP_KERNEL);
+
+	dprintk("<-- %s() succeeded\n", __func__);
+
+out:
+#ifdef USE_RPC_LOCK_CLIENT
+	rpc_unlock_client(clnt);
+#endif	/* USE_RPC_LOCK_CLIENT */
+	return error;
+}
+
+int nfs4_replace_transport(struct nfs_server *server)
+{
+	const size_t addr_bufsize = sizeof(struct sockaddr_storage);
+	struct sockaddr *sap;
+	size_t salen;
+	char *hostname;
+	size_t hostnamelen;
+	unsigned int i;
+	int error;
+
+	sap = kmalloc(addr_bufsize, GFP_KERNEL);
+	if (sap == NULL) {
+		error = -ENOMEM;
+		goto out;
+	}
+
+	error = -ENOENT;
+	/* Start after the current entry and search until the current entry */
+	for (i = (server->repli_current + 1) % NFS_MAX_REPLI_SERVERS;
+			i != server->repli_current;
+			i = (i + 1) % NFS_MAX_REPLI_SERVERS) {
+		if (server->repli_servers[i] == NULL)
+			continue;
+		hostname = server->repli_servers[i];
+		hostnamelen = strlen(hostname);
+		salen = nfs_parse_server_name(hostname, hostnamelen, sap,
+					      addr_bufsize);
+		if (salen == 0)
+			continue;
+		rpc_set_port(sap, NFS_PORT);
+		error = nfs4_update_server(server, hostname, sap, salen);
+		if (error == 0) {
+			dprintk("%s(): updated with server: %s\n",
+				__func__, hostname);
+			server->repli_current = i;
+			break;
+		}
+	}
+
+out:
+	return error;
+}
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4970c58..f5fd4bb 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -160,6 +160,7 @@ struct nfs_server {
 	struct nfs_fh		*rootfh;
 #define NFS_MAX_REPLI_SERVERS 2
 	char *repli_servers[NFS_MAX_REPLI_SERVERS];
+	int repli_current; /* Current serving replica index */
 
 	atomic_t active; /* Keep trace of any activity to this server */
 
-- 
1.7.8.3

