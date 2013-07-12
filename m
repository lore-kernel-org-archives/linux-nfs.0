Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f49.google.com ([209.85.213.49]:43644 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965117Ab3GLREi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 13:04:38 -0400
Received: by mail-yh0-f49.google.com with SMTP id v1so3734144yhn.8
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 10:04:37 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id h26sm68992590yhb.21.2013.07.12.09.33.21
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:33:21 -0700 (PDT)
Subject: [PATCH v1 13/19] NFS: Add functions to swap transports during
 migration recovery
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:33:20 -0400
Message-ID: <20130712163320.1444.73672.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce functions that can walk through an array of returned
fs_locations information and connect a transport to one of the
destination servers listed therein.

Note that NFS minor version 1 introduces "fs_locations_info" which
extends the locations array sorting criteria available to clients.
This is not supported yet.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/client.c        |    3 +
 fs/nfs/internal.h      |    3 +
 fs/nfs/nfs4_fs.h       |    2 +
 fs/nfs/nfs4client.c    |   78 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs4namespace.c |  114 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 199 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dbb65fb..5b7c60a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -945,7 +945,7 @@ void nfs_server_insert_lists(struct nfs_server *server)
 }
 EXPORT_SYMBOL_GPL(nfs_server_insert_lists);
 
-static void nfs_server_remove_lists(struct nfs_server *server)
+void nfs_server_remove_lists(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_net *nn;
@@ -962,6 +962,7 @@ static void nfs_server_remove_lists(struct nfs_server *server)
 
 	synchronize_rcu();
 }
+EXPORT_SYMBOL_GPL(nfs_server_remove_lists);
 
 /*
  * Allocate and initialise a server record
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 91e59a3..3de40da 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -153,6 +153,7 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
 				  rpc_authflavor_t);
 int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *, struct nfs_fattr *);
 void nfs_server_insert_lists(struct nfs_server *);
+void nfs_server_remove_lists(struct nfs_server *);
 void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
 int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *t,
 		rpc_authflavor_t);
@@ -173,6 +174,8 @@ extern struct nfs_server *nfs4_create_server(
 					struct nfs_subversion *);
 extern struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *,
 						      struct nfs_fh *);
+extern int nfs4_update_server(struct nfs_server *server, const char *hostname,
+					struct sockaddr *sap, size_t salen);
 extern void nfs_free_server(struct nfs_server *server);
 extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fh *,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b9c839e..4b83ffc 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -219,6 +219,8 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
 struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
 			       struct nfs_fh *, struct nfs_fattr *);
+int nfs4_replace_transport(struct nfs_server *server,
+				const struct nfs4_fs_locations *locations);
 
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 4d208e0..dadd118 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -920,3 +920,81 @@ error:
 	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
+
+/**
+ * nfs4_update_server - Replace transitioned nfs_server's transport
+ *
+ * @server: FSID whose transport will be replaced
+ * @hostname: new end-point's hostname
+ * @sap: new end-point's socket address
+ * @salen: size of "sap"
+ *
+ * Returns zero on success, or a negative errno value.
+ */
+int nfs4_update_server(struct nfs_server *server, const char *hostname,
+		       struct sockaddr *sap, size_t salen)
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
+	struct nfs_fh *mntfh;
+	int error;
+
+	dprintk("--> %s: move FSID %llx:%llx to \"%s\")\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor,
+			hostname);
+
+	error = rpc_switch_client_transport(clnt, &xargs, clnt->cl_timeout);
+	if (error != 0) {
+		dprintk("<-- %s(): rpc_switch_client_transport returned %d\n",
+			__func__, error);
+		goto out;
+	}
+
+	error = rpc_localaddr(clnt, localaddr, sizeof(address));
+	if (error != 0) {
+		dprintk("<-- %s(): rpc_localaddr returned %d\n",
+			__func__, error);
+		goto out;
+	}
+
+	error = -EAFNOSUPPORT;
+	if (rpc_ntop(localaddr, buf, sizeof(buf)) == 0) {
+		dprintk("<-- %s(): rpc_ntop returned %d\n",
+			__func__, error);
+		goto out;
+	}
+
+	nfs_server_remove_lists(server);
+	error = nfs4_set_client(server, hostname, sap, salen, buf,
+				clp->cl_rpcclient->cl_auth->au_flavor,
+				clp->cl_proto, clnt->cl_timeout,
+				clp->cl_minorversion, clp->cl_net);
+	if (error != 0) {
+		dprintk("<-- %s(): nfs4_set_client returned %d\n",
+			__func__, error);
+		goto out;
+	}
+
+	if (server->nfs_client->cl_hostname == NULL)
+		server->nfs_client->cl_hostname = kstrdup(hostname, GFP_KERNEL);
+
+	mntfh = NFS_FH(server->super->s_root->d_inode);
+	error = nfs4_server_common_setup(server, mntfh);
+	if (error < 0)
+		goto out;
+
+	dprintk("<-- %s() succeeded\n", __func__);
+out:
+	return error;
+}
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index cdb0b41..2459e60 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -387,3 +387,117 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 	rpc_shutdown_client(client);
 	return mnt;
 }
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
+		if (memchr(buf->data, IPV6_SCOPE_DELIMITER, buf->len) != NULL)
+			continue;
+
+		salen = nfs_parse_server_name(buf->data, buf->len,
+						sap, addr_bufsize, server);
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

