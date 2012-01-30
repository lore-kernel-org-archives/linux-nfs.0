Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:55677 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab2A3Tap (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:45 -0500
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:45 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id CDCB919D8059
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:05 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTwTT109960
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTvAw030581
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:57 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTuCA030487
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:56 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/13] NFS: Add an API for cloning an nfs_client
Date: Mon, 30 Jan 2012 13:29:48 -0600
Message-Id: <1327951795-16400-7-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

After a migration event, we have to preserve the long-form client ID
or session ID the client used with the source server, and introduce it
to the destination server, in case the migration transparently
migrated state for the migrating FSID.

To preserve this state information, clone the source FSID's
nfs_client.  The migrated FSID is moved from the original nfs_client
to the cloned one.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/client.c   |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/internal.h |    4 ++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index be5e702..3e3c2ff 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1435,6 +1435,52 @@ error:
 	return error;
 }
 
+int nfs4_clone_client(struct nfs_client *clp, const struct sockaddr *sap,
+		      size_t salen, const char *ip_addr,
+		      struct nfs_server *server)
+{
+	struct rpc_clnt *rpcclnt = clp->cl_rpcclient;
+	struct nfs_client_initdata cl_init = {
+		.addr		= sap,
+		.addrlen	= salen,
+		.rpc_ops	= &nfs_v4_clientops,
+		.proto		= rpc_protocol(rpcclnt),
+		.minorversion	= clp->cl_minorversion,
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
+	/*
+	 * The client ID verifier is derived from cl_boot_time.
+	 * This verifier must not change, or callback update will
+	 * act like a regular SETCLIENTID, causing the server to
+	 * lose state.
+	 */
+	new->cl_boot_time = clp->cl_boot_time;
+
+	dprintk("<-- %s moved (%llx:%llx) to nfs_client %p\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor, new);
+
+out:
+	return status;
+}
+
 /*
  * Set up a pNFS Data Server client.
  *
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8102db9..93c8daa 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -165,6 +165,10 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
+extern int nfs4_clone_client(struct nfs_client *clp,
+			     const struct sockaddr *sap, size_t salen,
+			     const char *ip_addr,
+			     struct nfs_server *server);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     const struct sockaddr *ds_addr,
 					     int ds_addrlen, int ds_proto);
-- 
1.7.8.3

