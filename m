Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50973 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab1CJRaL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:30:11 -0500
Received: by iyb26 with SMTP id 26so1753948iyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2011 09:30:11 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] NFS: Add functions to swap transports during migration
	recovery
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Mar 2011 12:30:08 -0500
Message-ID: <20110310173008.8878.71169.stgit@matisse.1015granger.net>
In-Reply-To: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Introduce functions that can walk through an array of returned
fs_locations information and connect a transport to one of the
destination servers listed therein.

Note that minor version 1 introduces "fs_locations_info" which
extends the sorting information available to clients.  This is
not supported yet.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h      |    2 +
 fs/nfs/nfs4namespace.c |  162 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 164 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 58a9ad7..bf2a4e7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -164,6 +164,8 @@ static inline void nfs_fs_proc_exit(void)
 /* nfs4namespace.c */
 #ifdef CONFIG_NFS_V4
 extern struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentry *dentry);
+extern int nfs4_replace_transport(struct nfs_server *server,
+		const struct nfs4_fs_locations *locations);
 #else
 static inline
 struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentry *dentry)
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 3c2a172..ea591ff 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -270,3 +270,165 @@ out:
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
+	 * when we are done recovering.  But they have bumped active_tasks,
+	 * so rpc_lock_client() can't make any progress.
+	 */
+#if 0
+	error = rpc_lock_client(clnt, clnt->cl_timeout->to_maxval);
+	if (error != 0)
+		goto out;
+#endif
+
+	error = rpc_switch_client_transport(clnt, &xargs, clnt->cl_timeout);
+
+out:
+#if 0
+	rpc_unlock_client(clnt);
+#endif
+	dprintk("<-- %s() = %d\n", __func__, error);
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

