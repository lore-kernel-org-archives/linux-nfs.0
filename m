Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41311 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758788Ab1DYSoy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:44:54 -0400
Received: by mail-iy0-f174.google.com with SMTP id 14so2054039iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:44:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/15] NFS: Add an API for cloning an nfs_client
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:44:50 -0400
Message-ID: <20110425184450.5669.69719.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

After a migration event, we have to preserve the client ID the client
used with the source server, and introduce it to the destination
server, in case the migration transparently migrated state for the
migrating FSID.

Note that our RENEW and SETCLIENTID procs both take an nfs_client as
an argument.  Thus, after a successful migration recovery, we want to
have a nfs_client with the correct long-form and short-form client ID
for the destination server to pass these procs.

To preserve the client IDs, we clone the source server's nfs_client.
The migrated FSID is moved from the original nfs_client to the cloned
one.

This patch introduces an API for cloning an nfs_client and moving an
FSID to it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c   |   69 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h |    4 +++
 2 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 42b579d..eb5cf55 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -135,6 +135,7 @@ struct nfs_client_initdata {
 	const struct nfs_rpc_ops *rpc_ops;
 	int proto;
 	u32 minorversion;
+	const char *long_clientid;
 };
 
 /*
@@ -184,6 +185,9 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+	if (cl_init->long_clientid != NULL)
+		clp->cl_cached_clientid = kstrdup(cl_init->long_clientid,
+							GFP_KERNEL);
 #endif
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
@@ -476,6 +480,10 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		/* Match the full socket address */
 		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
+		/* Match on long-form client ID */
+		if (data->long_clientid && clp->cl_cached_clientid &&
+		    strcmp(data->long_clientid, clp->cl_cached_clientid))
+			continue;
 
 		atomic_inc(&clp->cl_count);
 		return clp;
@@ -1432,8 +1440,65 @@ error:
 	return error;
 }
 
-/*
- * Set up a pNFS Data Server client.
+/**
+ * nfs4_clone_client - Clone a client after a migration event
+ * clp: nfs_client to clone
+ * sap: address of destination server
+ * salen: size of "sap" in bytes
+ * ip_addr: NUL-terminated string containing local presentation address
+ * server: nfs_server to move from "clp" to the new one
+ *
+ * Returns negative errno or zero.  nfs_client field of "server" is
+ * updated to refer to a new or existing nfs_client that matches
+ * [server address, port, version, minorversion, client ID].  The
+ * nfs_server is moved from the old nfs_client's cl_superblocks list
+ * to the new nfs_client's list.
+ */
+int nfs4_clone_client(struct nfs_client *clp, const struct sockaddr *sap,
+		      size_t salen, const char *ip_addr,
+		      struct nfs_server *server)
+{
+	struct rpc_clnt *rpcclnt = clp->cl_rpcclient;
+	struct nfs_client_initdata cl_init = {
+		.addr		= sap,
+		.addrlen	= salen,
+		.rpc_ops	= &nfs_v4_clientops,
+		.proto		= rcu_dereference(rpcclnt->cl_xprt)->prot,
+		.minorversion	= clp->cl_minorversion,
+		.long_clientid	= clp->cl_cached_clientid,
+	};
+	struct nfs_client *new;
+	int status = 0;
+
+	dprintk("--> %s cloning \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
+	new = nfs_get_client(&cl_init, rpcclnt->cl_timeout, ip_addr,
+				rpcclnt->cl_auth->au_flavor, 0);
+	if (IS_ERR(new)) {
+		dprintk("<-- %s nfs_get_client failed\n", __func__);
+		status = PTR_ERR(new);
+		goto out;
+	}
+
+	nfs_server_remove_lists(server);
+	server->nfs_client = new;
+	nfs_server_insert_lists(server);
+
+	dprintk("<-- %s moved (%llx:%llx) to nfs_client %p\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor, new);
+
+out:
+	return status;
+}
+
+/**
+ * nfs4_set_ds_client - Set up a pNFS Data Server client
+ * mds_clp: nfs_client representing the MDS
+ * ds_addr: IP address of DS
+ * ds_addrlen: size of "ds_addr" in bytes
+ * ds_proto: transport protocol to use to contact DS
  *
  * Return any existing nfs_client that matches server address,port,version
  * and minorversion.
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f6baf5b..0bf4e67 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -154,6 +154,10 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
+extern int nfs4_clone_client(struct nfs_client *clp,
+				const struct sockaddr *sap, size_t salen,
+				const char *ip_addr,
+				struct nfs_server *server);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     const struct sockaddr *ds_addr,
 					     int ds_addrlen, int ds_proto);

