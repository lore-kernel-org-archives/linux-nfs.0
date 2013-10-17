Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22651 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758391Ab3JQSMa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:30 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICS6j012525
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:29 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICScN018689
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:28 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/21] NFS: Add nfs4_update_server
Date: Thu, 17 Oct 2013 14:12:28 -0400
Message-Id: <20131017181228.1073.14811.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New function nfs4_update_server() moves an nfs_server to a different
nfs_client.  This is done as part of migration recovery.

Though it may be appealing to think of them as the same thing,
migration recovery is not the same as following a referral.

For a referral, the client has not descended into the file system
yet: it has no nfs_server, no super block, no inodes or open state.
It is enough to simply instantiate the nfs_server and super block,
and perform a referral mount.

For a migration, however, we have all of those things already, and
they have to be moved to a different nfs_client.  No local namespace
changes are needed here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/client.c     |    3 +
 fs/nfs/internal.h   |    3 +
 fs/nfs/nfs4client.c |  108 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 113 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2dceee4..f2e870c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -943,7 +943,7 @@ void nfs_server_insert_lists(struct nfs_server *server)
 }
 EXPORT_SYMBOL_GPL(nfs_server_insert_lists);
 
-static void nfs_server_remove_lists(struct nfs_server *server)
+void nfs_server_remove_lists(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs_net *nn;
@@ -960,6 +960,7 @@ static void nfs_server_remove_lists(struct nfs_server *server)
 
 	synchronize_rcu();
 }
+EXPORT_SYMBOL_GPL(nfs_server_remove_lists);
 
 /*
  * Allocate and initialise a server record
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 38da8c2..e5a6bd1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -154,6 +154,7 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
 				  rpc_authflavor_t);
 int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *, struct nfs_fattr *);
 void nfs_server_insert_lists(struct nfs_server *);
+void nfs_server_remove_lists(struct nfs_server *);
 void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
 int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *t,
 		rpc_authflavor_t);
@@ -174,6 +175,8 @@ extern struct nfs_server *nfs4_create_server(
 					struct nfs_subversion *);
 extern struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *,
 						      struct nfs_fh *);
+extern int nfs4_update_server(struct nfs_server *server, const char *hostname,
+					struct sockaddr *sap, size_t salen);
 extern void nfs_free_server(struct nfs_server *server);
 extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fh *,
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index a860ab5..299cf6b 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1091,3 +1091,111 @@ error:
 	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
+
+/*
+ * Grab the destination's particulars, including lease expiry time.
+ *
+ * Returns zero if probe succeeded and retrieved FSID matches the FSID
+ * we have cached.
+ */
+static int nfs_probe_destination(struct nfs_server *server)
+{
+	struct inode *inode = server->super->s_root->d_inode;
+	struct nfs_fattr *fattr;
+	int error;
+
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		return -ENOMEM;
+
+	/* Sanity: the probe won't work if the destination server
+	 * does not recognize the migrated FH. */
+	error = nfs_probe_fsinfo(server, NFS_FH(inode), fattr);
+
+	nfs_free_fattr(fattr);
+	return error;
+}
+
+/**
+ * nfs4_update_server - Move an nfs_server to a different nfs_client
+ *
+ * @server: represents FSID to be moved
+ * @hostname: new end-point's hostname
+ * @sap: new end-point's socket address
+ * @salen: size of "sap"
+ *
+ * The nfs_server must be quiescent before this function is invoked.
+ * Either its session is drained (NFSv4.1+), or its transport is
+ * plugged and drained (NFSv4.0).
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
+	nfs_put_client(clp);
+	if (error != 0) {
+		nfs_server_insert_lists(server);
+		dprintk("<-- %s(): nfs4_set_client returned %d\n",
+			__func__, error);
+		goto out;
+	}
+
+	if (server->nfs_client->cl_hostname == NULL)
+		server->nfs_client->cl_hostname = kstrdup(hostname, GFP_KERNEL);
+	nfs_server_insert_lists(server);
+
+	error = nfs_probe_destination(server);
+	if (error < 0)
+		goto out;
+
+	dprintk("<-- %s() succeeded\n", __func__);
+
+out:
+	return error;
+}

