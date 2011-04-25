Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41311 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758788Ab1DYSpE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:45:04 -0400
Received: by mail-iy0-f174.google.com with SMTP id 14so2054039iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:45:04 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/15] NFS: Add functions to swap transports during migration
	recovery
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:45:01 -0400
Message-ID: <20110425184501.5669.45755.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Introduce functions that can walk through an array of returned
fs_locations information and connect a transport to one of the
destination servers listed therein.

Note that NFS minor version 1 introduces "fs_locations_info" which
extends the locations array sorting criteria available to clients.
This is not supported yet.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h      |    2 
 fs/nfs/nfs4namespace.c |  202 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 204 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0bf4e67..191c5b4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -177,6 +177,8 @@ static inline void nfs_fs_proc_exit(void)
 /* nfs4namespace.c */
 #ifdef CONFIG_NFS_V4
 extern struct vfsmount *nfs_do_refmount(struct dentry *dentry);
+extern int nfs4_replace_transport(struct nfs_server *server,
+		const struct nfs4_fs_locations *locations);
 #else
 static inline
 struct vfsmount *nfs_do_refmount(struct dentry *dentry)
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index bb80c49..2fa024c 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -22,6 +22,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+#undef USE_RPC_LOCK_CLIENT
+
 /*
  * Convert the NFSv4 pathname components into a standard posix path.
  *
@@ -263,3 +265,203 @@ out:
 	dprintk("%s: done\n", __func__);
 	return mnt;
 }
+
+#undef NFSDBG_FACILITY
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
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
+/*
+ * Try one location from the fs_locations array.
+ *
+ * Returns zero on success, or a negative errno value.
+ */
+static int nfs4_try_replacing_one_location(struct nfs_server *server,
+		char *page, char *page2,
+		const struct nfs4_fs_location *location)
+{
+	const size_t addr_bufsize = sizeof(struct sockaddr_storage);
+	struct sockaddr *sap;
+	unsigned int s;
+	size_t salen;
+	int error;
+
+	dprintk("--> %s(%llx:%llx)\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor);
+
+	error = -ENOMEM;
+	sap = kmalloc(addr_bufsize, GFP_KERNEL);
+	if (sap == NULL)
+		goto out;
+
+	error = -ENOENT;
+	for (s = 0; s < location->nservers; s++) {
+		const struct nfs4_string *buf = &location->servers[s];
+		char *hostname;
+
+		if (buf->len <= 0 || buf->len > PAGE_SIZE)
+			continue;
+
+		/* XXX: IPv6 not supported? */
+		if (memchr(buf->data, IPV6_SCOPE_DELIMITER, buf->len) != NULL)
+			continue;
+
+		salen = nfs_parse_server_name(buf->data, buf->len,
+						sap, addr_bufsize);
+		if (salen == 0)
+			continue;
+		rpc_set_port(sap, NFS_PORT);
+
+		error = -ENOMEM;
+		hostname = kstrndup(buf->data, buf->len, GFP_KERNEL);
+		if (hostname == NULL)
+			break;
+
+		error = nfs4_update_server(server, hostname, sap, salen);
+		kfree(hostname);
+		if (error == 0)
+			break;
+	}
+
+	kfree(sap);
+out:
+	dprintk("<-- %s() = %d\n", __func__, error);
+	return error;
+}
+
+/**
+ * nfs4_replace_transport - set up transport to destination server
+ *
+ * @server: export being migrated
+ * @locations: fs_locations array
+ *
+ * Returns zero on success, or a negative errno value.
+ *
+ * The client tries all the entries in the "locations" array, in the
+ * order returned by the server, until one works or the end of the
+ * array is reached.
+ */
+int nfs4_replace_transport(struct nfs_server *server,
+			   const struct nfs4_fs_locations *locations)
+{
+	char *page = NULL, *page2 = NULL;
+	int loc, error;
+
+	dprintk("--> %s(%llx:%llx)\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor);
+
+	error = -ENOENT;
+	if (locations == NULL || locations->nlocations <= 0)
+		goto out;
+
+	error = -ENOMEM;
+	page = (char *) __get_free_page(GFP_USER);
+	if (!page)
+		goto out;
+	page2 = (char *) __get_free_page(GFP_USER);
+	if (!page2)
+		goto out;
+
+	for (loc = 0; loc < locations->nlocations; loc++) {
+		const struct nfs4_fs_location *location =
+						&locations->locations[loc];
+
+		if (location == NULL || location->nservers <= 0 ||
+		    location->rootpath.ncomponents == 0)
+			continue;
+
+		error = nfs4_try_replacing_one_location(server, page,
+							page2, location);
+		if (error == 0)
+			break;
+	}
+
+out:
+	free_page((unsigned long)page);
+	free_page((unsigned long)page2);
+
+	dprintk("<-- %s() = %d\n", __func__, error);
+	return error;
+}

