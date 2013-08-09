Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f179.google.com ([209.85.213.179]:50614 "EHLO
	mail-ye0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968210Ab3HIQuf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:50:35 -0400
Received: by mail-ye0-f179.google.com with SMTP id m15so1303185yen.38
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:50:33 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id b48sm20693442yhc.8.2013.08.09.09.50.32
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:50:33 -0700 (PDT)
Subject: [PATCH v2 19/33] NFS: Add functions to swap transports during
 migration recovery
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:50:32 -0400
Message-ID: <20130809165032.5362.21297.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
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
 fs/nfs/nfs4_fs.h       |    2 +
 fs/nfs/nfs4namespace.c |  101 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 103 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af2d5bf..75b2335 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -216,6 +216,8 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
 struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
 			       struct nfs_fh *, struct nfs_fattr *);
+int nfs4_replace_transport(struct nfs_server *server,
+				const struct nfs4_fs_locations *locations);
 
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index cdb0b41..faa8b80 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -387,3 +387,104 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
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
+	sap = kmalloc(addr_bufsize, GFP_KERNEL);
+	if (sap == NULL)
+		return -ENOMEM;
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
+	return error;
+}

