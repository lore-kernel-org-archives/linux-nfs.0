Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:59304 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030594Ab3HIQuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:50:25 -0400
Received: by mail-yh0-f52.google.com with SMTP id f11so1522938yha.11
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:50:25 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id i70sm12888048yhd.4.2013.08.09.09.50.24
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:50:24 -0700 (PDT)
Subject: [PATCH v2 18/33] NFS: Add nfs4_update_server
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:50:23 -0400
Message-ID: <20130809165023.5362.60011.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New function nfs4_update_server() moves an nfs_server to a different
nfs_client.  This is done as part of migration recovery.

Though it may be appealing to think of them as the same thing, a
migration recovery is not the same as following a referral.

For a referral, the client has not descended into the file system
yet: it has no nfs_server, no super block, no inodes or open state.
It is enough to simply instantiate the nfs_server and super block.

For a migration, however, we have all of those things already, and
they have to be moved to a different nfs_client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/client.c     |    3 +-
 fs/nfs/internal.h   |    3 ++
 fs/nfs/nfs4client.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 92 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 340b1ef..783b868 100644
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
index 3c8373f..8392278 100644
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
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index eedd686..d462e40 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -968,3 +968,90 @@ error:
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
+ * The nfs_server must be quiescent before this function is invoked.
+ * Either its session is drained, or the transport is plugged and
+ * drained.
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
+	error = -ENOMEM;
+	mntfh = nfs_alloc_fhandle();
+	if (mntfh == NULL)
+		goto out;
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
+	error = nfs4_server_common_setup(server, mntfh);
+	if (error < 0)
+		goto out;
+
+	dprintk("<-- %s() succeeded\n", __func__);
+out:
+	nfs_free_fhandle(mntfh);
+	return error;
+}

