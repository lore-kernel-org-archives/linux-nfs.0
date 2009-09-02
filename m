From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 5/8] nfsv4: Add nfsv4 rpc client side support
Date: Wed,  2 Sep 2009 17:54:25 +0530
Message-ID: <1251894268-1555-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:48545 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbZIBMZI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:25:08 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82CP8HQ000799
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:08 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82CP8du2449576
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:08 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82CP7p8001582
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:25:08 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/client.c         |   32 +++++++----
 fs/nfs/nfs4xdr.c        |  149 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_xdr.h |   25 ++++++++
 include/linux/nfsacl.h  |    2 +
 4 files changed, 197 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ea3a6b7..31f4a0b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -81,11 +81,15 @@ struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
 };
 
-
-#ifdef CONFIG_NFS_V3_ACL
+#if defined(CONFIG_NFS_V3_ACL) || defined(CONFIG_NFS4_FS_POSIX_ACL)
 static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
 static struct rpc_version *	nfsacl_version[] = {
+#ifdef CONFIG_NFS_V3_ACL
 	[3]			= &nfsacl_version3,
+#endif
+#ifdef CONFIG_NFS4_FS_POSIX_ACL
+	[4]			= &nfspacl_version4,
+#endif
 };
 
 struct rpc_program		nfsacl_program = {
@@ -670,17 +674,18 @@ static int nfs_start_lockd(struct nfs_server *server)
 }
 
 /*
- * Initialise an NFSv3 ACL client connection
+ * Initialise an NFSv3/NFSv4 ACL client connection
  */
-#ifdef CONFIG_NFS_V3_ACL
-static void nfs_init_server_aclclient(struct nfs_server *server)
+#if defined(CONFIG_NFS_V3_ACL) ||  defined(CONFIG_NFS4_FS_POSIX_ACL)
+static void nfs_init_server_aclclient(struct nfs_server *server, int version)
 {
-	if (server->nfs_client->rpc_ops->version != 3)
+	if (server->nfs_client->rpc_ops->version != version)
 		goto out_noacl;
 	if (server->flags & NFS_MOUNT_NOACL)
 		goto out_noacl;
 
-	server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
+	server->client_acl = rpc_bind_new_program(server->client,
+						&nfsacl_program, version);
 	if (IS_ERR(server->client_acl))
 		goto out_noacl;
 
@@ -692,7 +697,8 @@ out_noacl:
 	server->caps &= ~NFS_CAP_PACLS;
 }
 #else
-static inline void nfs_init_server_aclclient(struct nfs_server *server)
+static inline void nfs_init_server_aclclient(struct nfs_server *server,
+					int version)
 {
 	server->flags &= ~NFS_MOUNT_NOACL;
 	server->caps &= ~NFS_CAP_PACLS;
@@ -843,7 +849,7 @@ static int nfs_init_server(struct nfs_server *server,
 
 	server->namelen  = data->namlen;
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
-	nfs_init_server_aclclient(server);
+	nfs_init_server_aclclient(server, 3);
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
@@ -1303,7 +1309,10 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->port = data->nfs_server.port;
 
 	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
-
+	if (error < 0)
+		goto error;
+	/* Create a client RPC handle for the NFSv4 ACL management interface */
+	nfs_init_server_aclclient(server, 4);
 error:
 	/* Done */
 	dprintk("<-- nfs4_init_server() = %d\n", error);
@@ -1490,7 +1499,8 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	if (error < 0)
 		goto out_free_server;
 	if (!IS_ERR(source->client_acl))
-		nfs_init_server_aclclient(server);
+		nfs_init_server_aclclient(server,
+					source->nfs_client->rpc_ops->version);
 
 	/* probe the filesystem info for this server filesystem */
 	error = nfs_probe_fsinfo(server, fh, &fattr_fsinfo);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 617273e..eac604e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5502,8 +5502,157 @@ struct rpc_version		nfs_version4 = {
 	.procs			= nfs4_procedures
 };
 
+#ifdef CONFIG_NFS4_FS_POSIX_ACL
+
+#define NFS4_fh_sz            (1 + (NFS4_FHSIZE >> 2))
+#define NFS4_getpaclargs_sz   (NFS4_fh_sz + 1)
+#define NFS4_setpaclargs_sz   (NFS4_fh_sz + 1 + XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
+#define NFS4_getpaclres_sz    (1 + 1 + XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
+#define NFS4_setpaclres_sz    (1)
+
+/*
+ * Encode GETACL arguments
+ */
+static inline __be32 *
+nfs4_xdr_encode_fhandle(__be32 *p, const struct nfs_fh *fh)
+{
+	return xdr_encode_array(p, fh->data, fh->size);
+}
+
+static int
+nfs4_xdr_getpaclargs(struct rpc_rqst *req, __be32 *p,
+		    struct nfs4_getpaclargs *args)
+{
+	struct rpc_auth	*auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	unsigned int replen;
+
+	p = nfs4_xdr_encode_fhandle(p, args->fh);
+	*p++ = htonl(args->mask);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+
+	if (args->mask & (NFS_ACL | NFS_DFACL)) {
+		/* Inline the page array */
+		replen = (RPC_REPHDRSIZE + auth->au_rslack +
+			  NFS4_getpaclres_sz) << 2;
+		xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages, 0,
+				 NFSACL_MAXPAGES << PAGE_SHIFT);
+	}
+	return 0;
+}
+
+/*
+ * Encode SETACL arguments
+ */
+static int
+nfs4_xdr_setpaclargs(struct rpc_rqst *req, __be32 *p,
+		struct nfs4_setpaclargs *args)
+{
+	struct xdr_buf *buf = &req->rq_snd_buf;
+	unsigned int base;
+	int err;
+
+	p = nfs4_xdr_encode_fhandle(p, NFS_FH(args->inode));
+	*p++ = htonl(args->mask);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	base = req->rq_slen;
+
+	if (args->npages != 0)
+		xdr_encode_pages(buf, args->pages, 0, args->len);
+	else
+		req->rq_slen = xdr_adjust_iovec(req->rq_svec,
+				p + XDR_QUADLEN(args->len));
+
+	err = nfsacl_encode(buf, base, args->inode,
+			    (args->mask & NFS_ACL) ?
+			    args->acl_access : NULL, 1, 0);
+	if (err > 0)
+		err = nfsacl_encode(buf, base + err, args->inode,
+				    (args->mask & NFS_DFACL) ?
+				    args->acl_default : NULL, 1,
+				    NFS_ACL_DEFAULT);
+	return (err > 0) ? 0 : err;
+}
+
+/*
+ * Decode GETACL reply
+ */
+static int
+nfs4_xdr_getpaclres(struct rpc_rqst *req, __be32 *p,
+		   struct nfs4_getpaclres *res)
+{
+	struct xdr_buf *buf = &req->rq_rcv_buf;
+	int status = ntohl(*p++);
+	struct posix_acl **acl;
+	unsigned int *aclcnt;
+	int err, base;
+
+	if (status != 0)
+		return nfs4_stat_to_errno(status);
+	res->mask = ntohl(*p++);
+	if (res->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
+		return -EINVAL;
+	base = (char *)p - (char *)req->rq_rcv_buf.head->iov_base;
+
+	acl = (res->mask & NFS_ACL) ? &res->acl_access : NULL;
+	aclcnt = (res->mask & NFS_ACLCNT) ? &res->acl_access_count : NULL;
+	err = nfsacl_decode(buf, base, aclcnt, acl);
+
+	acl = (res->mask & NFS_DFACL) ? &res->acl_default : NULL;
+	aclcnt = (res->mask & NFS_DFACLCNT) ? &res->acl_default_count : NULL;
+	if (err > 0)
+		err = nfsacl_decode(buf, base + err, aclcnt, acl);
+	return (err > 0) ? 0 : err;
+}
+
+/*
+ * Decode setacl reply.
+ */
+static int
+nfs4_xdr_setpaclres(struct rpc_rqst *req, __be32 *p, void *dummy)
+{
+	int status = ntohl(*p++);
+
+	if (status)
+		return nfs4_stat_to_errno(status);
+	return 0;
+}
+
+static struct rpc_procinfo nfs4_pacl_procedures[] = {
+	[NFSPROC4_CLNT_GETPACL] = {
+		.p_proc = NFSPROC4_CLNT_GETPACL,
+		.p_encode = (kxdrproc_t) nfs4_xdr_getpaclargs,
+		.p_decode = (kxdrproc_t) nfs4_xdr_getpaclres,
+		.p_arglen = NFS4_getpaclargs_sz,
+		.p_replen = NFS4_getpaclres_sz,
+		.p_statidx = NFSPROC4_CLNT_GETPACL,
+		.p_timer = 1,
+		.p_name = "GETPACL",
+	},
+	[NFSPROC4_CLNT_SETPACL] = {
+		.p_proc = NFSPROC4_CLNT_SETPACL,
+		.p_encode = (kxdrproc_t) nfs4_xdr_setpaclargs,
+		.p_decode = (kxdrproc_t) nfs4_xdr_setpaclres,
+		.p_arglen = NFS4_setpaclargs_sz,
+		.p_replen = NFS4_setpaclres_sz,
+		.p_statidx = NFSPROC4_CLNT_SETPACL,
+		.p_timer = 0,
+		.p_name = "SETPACL",
+	},
+};
+
+struct rpc_version		nfspacl_version4 = {
+	.number			= 4,
+	.nrprocs		= sizeof(nfs4_pacl_procedures)/
+				  sizeof(nfs4_pacl_procedures[0]),
+	.procs			= nfs4_pacl_procedures,
+};
+#endif  /* CONFIG_NFS4_FS_POSIX_ACL */
+
 /*
  * Local variables:
  *  c-basic-offset: 8
  * End:
  */
+
+/*  LocalWords:  nfs
+ */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 62f63fb..39acac6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -886,6 +886,30 @@ struct nfs4_fs_locations_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
+struct nfs4_getpaclargs {
+	struct nfs_fh		*fh;
+	int			mask;
+	struct page		**pages;
+};
+
+struct nfs4_setpaclargs {
+	struct inode		*inode;
+	int			mask;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+	size_t			len;
+	unsigned int		npages;
+	struct page		**pages;
+};
+
+struct nfs4_getpaclres {
+	int			mask;
+	unsigned int		acl_access_count;
+	unsigned int		acl_default_count;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+};
+
 #endif /* CONFIG_NFS_V4 */
 
 struct nfstime4 {
@@ -1061,5 +1085,6 @@ extern struct rpc_version	nfs_version4;
 
 extern struct rpc_version	nfsacl_version3;
 extern struct rpc_program	nfsacl_program;
+extern struct rpc_version	nfspacl_version4;
 
 #endif
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 43011b6..15ffa58 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -16,6 +16,8 @@
 #define ACLPROC3_GETACL		1
 #define ACLPROC3_SETACL		2
 
+#define NFSPROC4_CLNT_GETPACL   1
+#define NFSPROC4_CLNT_SETPACL   2
 
 /* Flags for the getacl/setacl mode */
 #define NFS_ACL			0x0001
-- 
1.6.4.2.253.g0b1fac

