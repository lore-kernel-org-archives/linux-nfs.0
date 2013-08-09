Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f180.google.com ([209.85.160.180]:44368 "EHLO
	mail-gh0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968218Ab3HIQv4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:51:56 -0400
Received: by mail-gh0-f180.google.com with SMTP id f18so1293350ghb.39
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:51:55 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id v68sm20681429yhn.22.2013.08.09.09.51.54
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:51:55 -0700 (PDT)
Subject: [PATCH v2 28/33] NFS: Add method to detect whether an FSID is still
 on the server
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:51:54 -0400
Message-ID: <20130809165153.5362.51268.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a mechanism for probing a server to determine if an FSID
is present or absent.

The on-the-wire compound is different between minor version 0 and 1.
Minor version 0 appends a RENEW operation to identify which client
ID is probing.  Minor version 1 has a SEQUENCE operation in the
compound which effectively carries the same information.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h        |    2 +
 fs/nfs/nfs4proc.c       |  125 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |   67 ++++++++++++++++++++++++-
 include/linux/nfs4.h    |    1 
 include/linux/nfs_xdr.h |   13 +++++
 5 files changed, 206 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 2920746..b4d7559 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -207,6 +207,7 @@ struct nfs4_state_maintenance_ops {
 struct nfs4_mig_recovery_ops {
 	int (*get_locations)(struct inode *, struct nfs4_fs_locations *,
 		struct page *);
+	int (*fsid_present)(struct inode *);
 };
 
 extern const struct dentry_operations nfs4_dentry_operations;
@@ -241,6 +242,7 @@ extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struc
 				  struct nfs4_fs_locations *, struct page *);
 extern int nfs4_proc_get_locations(struct inode *, struct nfs4_fs_locations *,
 		struct page *page);
+extern int nfs4_proc_fsid_present(struct inode *);
 extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ae19cd5..36cd989 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6054,6 +6054,129 @@ int nfs4_proc_get_locations(struct inode *inode,
 	return status;
 }
 
+/*
+ * This operation also signals the server that this client is
+ * performing "lease moved" recovery.  The server can stop
+ * returning NFS4ERR_LEASE_MOVED to this client.  A RENEW operation
+ * is appended to this compound to identify the client ID which is
+ * performing recovery.
+ */
+static int _nfs40_proc_fsid_present(struct inode *inode)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+	struct rpc_clnt *clnt = clp->cl_rpcclient;
+	struct nfs4_fsid_present_arg args = {
+		.fh		= NFS_FH(inode),
+		.clientid	= clp->cl_clientid,
+		.renew		= 1,		/* append RENEW */
+	};
+	struct nfs4_fsid_present_res res = {
+		.renew		= 1,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_FSID_PRESENT],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+	unsigned long now = jiffies;
+	int status;
+
+	res.fh = nfs_alloc_fhandle();
+	if (res.fh == NULL)
+		return -ENOMEM;
+
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
+	nfs4_set_sequence_privileged(&args.seq_args);
+	status = nfs4_call_sync_sequence(clnt, server, &msg,
+						&args.seq_args, &res.seq_res);
+	nfs_free_fhandle(res.fh);
+	if (status)
+		return status;
+
+	do_renew_lease(clp, now);
+	return 0;
+}
+
+#ifdef CONFIG_NFS_V4_1
+
+/*
+ * This operation also signals the server that this client is
+ * performing "lease moved" recovery.  The server can stop asserting
+ * SEQ4_STATUS_LEASE_MOVED for this client.  The client ID performing
+ * this operation is identified in the SEQUENCE operation in this
+ * compound.
+ */
+static int _nfs41_proc_fsid_present(struct inode *inode)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct rpc_clnt *clnt = server->nfs_client->cl_rpcclient;
+	struct nfs4_fsid_present_arg args = {
+		.fh		= NFS_FH(inode),
+	};
+	struct nfs4_fsid_present_res res = {
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_FSID_PRESENT],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+	int status;
+
+	res.fh = nfs_alloc_fhandle();
+	if (res.fh == NULL)
+		return -ENOMEM;
+
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
+	nfs4_set_sequence_privileged(&args.seq_args);
+	status = nfs4_call_sync_sequence(clnt, server, &msg,
+						&args.seq_args, &res.seq_res);
+	nfs_free_fhandle(res.fh);
+	if (status == NFS4_OK &&
+	    res.seq_res.sr_status_flags & SEQ4_STATUS_LEASE_MOVED)
+		status = -NFS4ERR_LEASE_MOVED;
+	return status;
+}
+
+#endif	/* CONFIG_NFS_V4_1 */
+
+/**
+ * nfs4_proc_fsid_present - Is this FSID present or absent on server?
+ * @inode: inode on FSID to check
+ *
+ * Server indicates whether the FSID is present, moved, or not
+ * recognized.  This operation is necessary to clear a LEASE_MOVED
+ * condition for this client ID.
+ *
+ * Returns NFS4_OK if the FSID is present on this server,
+ * -NFS4ERR_MOVED if the FSID is no longer present, a negative
+ *  NFS4ERR code if some error occurred on the server, or a
+ *  negative errno if a local failure occurred.
+ */
+int nfs4_proc_fsid_present(struct inode *inode)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_client *clp = server->nfs_client;
+	const struct nfs4_mig_recovery_ops *ops =
+					clp->cl_mvops->mig_recovery_ops;
+	struct nfs4_exception exception = { };
+	int status;
+
+	dprintk("%s: FSID %llx:%llx on \"%s\"\n", __func__,
+		(unsigned long long)server->fsid.major,
+		(unsigned long long)server->fsid.minor,
+		clp->cl_hostname);
+	nfs_display_fhandle(NFS_FH(inode), __func__);
+
+	do {
+		status = ops->fsid_present(inode);
+		if (status != -NFS4ERR_DELAY)
+			break;
+		nfs4_handle_exception(server, status, &exception);
+	} while (exception.retry);
+	return status;
+}
+
 static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
 {
 	int status;
@@ -7672,11 +7795,13 @@ static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 
 static const struct nfs4_mig_recovery_ops nfs40_mig_recovery_ops = {
 	.get_locations = _nfs40_proc_get_locations,
+	.fsid_present = _nfs40_proc_fsid_present,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_mig_recovery_ops nfs41_mig_recovery_ops = {
 	.get_locations = _nfs41_proc_get_locations,
+	.fsid_present = _nfs41_proc_fsid_present,
 };
 #endif	/* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d098831..47e60c6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -591,11 +591,13 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_enc_getattr_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
-				encode_getattr_maxsz)
+				encode_getattr_maxsz + \
+				encode_renew_maxsz)
 #define NFS4_dec_getattr_sz	(compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
-				decode_getattr_maxsz)
+				decode_getattr_maxsz + \
+				decode_renew_maxsz)
 #define NFS4_enc_lookup_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
@@ -749,6 +751,18 @@ static int nfs4_stat_to_errno(int);
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_secinfo_maxsz)
+#define NFS4_enc_fsid_present_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_sequence_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_getfh_maxsz + \
+				 encode_renew_maxsz)
+#define NFS4_dec_fsid_present_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_getfh_maxsz + \
+				 decode_renew_maxsz)
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_enc_bind_conn_to_session_sz \
 				(compound_encode_hdr_maxsz + \
@@ -2722,6 +2736,26 @@ static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+/*
+ * Encode FSID_PRESENT request
+ */
+static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
+				      struct xdr_stream *xdr,
+				      struct nfs4_fsid_present_arg *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	encode_getfh(xdr, &hdr);
+	if (args->renew)
+		encode_renew(xdr, args->clientid, &hdr);
+	encode_nops(&hdr);
+}
+
 #if defined(CONFIG_NFS_V4_1)
 /*
  * BIND_CONN_TO_SESSION request
@@ -6863,6 +6897,34 @@ out:
 	return status;
 }
 
+/*
+ * Decode FSID_PRESENT response
+ */
+static int nfs4_xdr_dec_fsid_present(struct rpc_rqst *rqstp,
+				     struct xdr_stream *xdr,
+				     struct nfs4_fsid_present_res *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_getfh(xdr, res->fh);
+	if (status)
+		goto out;
+	if (res->renew)
+		status = decode_renew(xdr);
+out:
+	return status;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 /*
  * Decode BIND_CONN_TO_SESSION response
@@ -7377,6 +7439,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(FS_LOCATIONS,	enc_fs_locations,	dec_fs_locations),
 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
 	PROC(SECINFO,		enc_secinfo,		dec_secinfo),
+	PROC(FSID_PRESENT,	enc_fsid_present,	dec_fsid_present),
 #if defined(CONFIG_NFS_V4_1)
 	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
 	PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e36dee5..c56fa8f 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -460,6 +460,7 @@ enum {
 	NFSPROC4_CLNT_FS_LOCATIONS,
 	NFSPROC4_CLNT_RELEASE_LOCKOWNER,
 	NFSPROC4_CLNT_SECINFO,
+	NFSPROC4_CLNT_FSID_PRESENT,
 
 	/* nfs41 */
 	NFSPROC4_CLNT_EXCHANGE_ID,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9a6b776..89d6d3d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1088,6 +1088,19 @@ struct nfs4_secinfo_res {
 	struct nfs4_secinfo_flavors	*flavors;
 };
 
+struct nfs4_fsid_present_arg {
+	struct nfs4_sequence_args	seq_args;
+	const struct nfs_fh		*fh;
+	clientid4			clientid;
+	unsigned char			renew:1;
+};
+
+struct nfs4_fsid_present_res {
+	struct nfs4_sequence_res	seq_res;
+	struct nfs_fh			*fh;
+	unsigned char			renew:1;
+};
+
 #endif /* CONFIG_NFS_V4 */
 
 struct nfstime4 {

