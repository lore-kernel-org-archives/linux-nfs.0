Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22843 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758741Ab3JQSMw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:52 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICpVL012882
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:51 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICoBk026259
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:51 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/21] NFS: Add method to retrieve fs_locations during migration recovery
Date: Thu, 17 Oct 2013 14:12:50 -0400
Message-Id: <20131017181250.1073.75696.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs4_proc_fs_locations() function is invoked during referral
processing to perform a GETATTR(fs_locations) on an object's parent
directory in order to discover the target of the referral.  It
performs a LOOKUP in the compound, so the client needs to know the
parent's file handle a priori.

Unfortunately this function is not adequate for handling migration
recovery.  We need to probe fs_locations information on an FSID, but
there's no parent directory available for many operations that
can return NFS4ERR_MOVED.

Another subtlety: recovering from NFS4ERR_LEASE_MOVED is a process
of walking over a list of known FSIDs that reside on the server, and
probing whether they have migrated.  Once the server has detected
that the client has probed all migrated file systems, it stops
returning NFS4ERR_LEASE_MOVED.

A minor version zero server needs to know what client ID is
requesting fs_locations information so it can clear the flag that
forces it to continue returning NFS4ERR_LEASE_MOVED.  This flag is
set per client ID and per FSID.  However, the client ID is not an
argument of either the PUTFH or GETATTR operations.  Later minor
versions have client ID information embedded in the compound's
SEQUENCE operation.

Therefore, by convention, minor version zero clients send a RENEW
operation in the same compound as the GETATTR(fs_locations), since
RENEW's one argument is a clientid4.  This allows a minor version
zero server to identify correctly the client that is probing for a
migration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h        |    4 +
 fs/nfs/nfs4proc.c       |  153 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |   46 +++++++++++---
 include/linux/nfs_xdr.h |    4 +
 4 files changed, 196 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4f48000..e59d3b4 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -205,6 +205,8 @@ struct nfs4_state_maintenance_ops {
 };
 
 struct nfs4_mig_recovery_ops {
+	int (*get_locations)(struct inode *, struct nfs4_fs_locations *,
+		struct page *, struct rpc_cred *);
 };
 
 extern const struct dentry_operations nfs4_dentry_operations;
@@ -237,6 +239,8 @@ extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struct qstr *,
 				  struct nfs4_fs_locations *, struct page *);
+extern int nfs4_proc_get_locations(struct inode *, struct nfs4_fs_locations *,
+		struct page *page, struct rpc_cred *);
 extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e4bd317..f507e54 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5990,6 +5990,157 @@ int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 	return err;
 }
 
+/*
+ * This operation also signals the server that this client is
+ * performing migration recovery.  The server can stop returning
+ * NFS4ERR_LEASE_MOVED to this client.  A RENEW operation is
+ * appended to this compound to identify the client ID which is
+ * performing recovery.
+ */
+static int _nfs40_proc_get_locations(struct inode *inode,
+				     struct nfs4_fs_locations *locations,
+				     struct page *page, struct rpc_cred *cred)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct rpc_clnt *clnt = server->client;
+	u32 bitmask[2] = {
+		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
+	};
+	struct nfs4_fs_locations_arg args = {
+		.clientid	= server->nfs_client->cl_clientid,
+		.fh		= NFS_FH(inode),
+		.page		= page,
+		.bitmask	= bitmask,
+		.migration	= 1,		/* skip LOOKUP */
+		.renew		= 1,		/* append RENEW */
+	};
+	struct nfs4_fs_locations_res res = {
+		.fs_locations	= locations,
+		.migration	= 1,
+		.renew		= 1,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+		.rpc_cred	= cred,
+	};
+	unsigned long now = jiffies;
+	int status;
+
+	nfs_fattr_init(&locations->fattr);
+	locations->server = server;
+	locations->nlocations = 0;
+
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
+	nfs4_set_sequence_privileged(&args.seq_args);
+	status = nfs4_call_sync_sequence(clnt, server, &msg,
+					&args.seq_args, &res.seq_res);
+	if (status)
+		return status;
+
+	renew_lease(server, now);
+	return 0;
+}
+
+#ifdef CONFIG_NFS_V4_1
+
+/*
+ * This operation also signals the server that this client is
+ * performing migration recovery.  The server can stop asserting
+ * SEQ4_STATUS_LEASE_MOVED for this client.  The client ID
+ * performing this operation is identified in the SEQUENCE
+ * operation in this compound.
+ *
+ * When the client supports GETATTR(fs_locations_info), it can
+ * be plumbed in here.
+ */
+static int _nfs41_proc_get_locations(struct inode *inode,
+				     struct nfs4_fs_locations *locations,
+				     struct page *page, struct rpc_cred *cred)
+{
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct rpc_clnt *clnt = server->client;
+	u32 bitmask[2] = {
+		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
+	};
+	struct nfs4_fs_locations_arg args = {
+		.fh		= NFS_FH(inode),
+		.page		= page,
+		.bitmask	= bitmask,
+		.migration	= 1,		/* skip LOOKUP */
+	};
+	struct nfs4_fs_locations_res res = {
+		.fs_locations	= locations,
+		.migration	= 1,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+		.rpc_cred	= cred,
+	};
+	int status;
+
+	nfs_fattr_init(&locations->fattr);
+	locations->server = server;
+	locations->nlocations = 0;
+
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
+	nfs4_set_sequence_privileged(&args.seq_args);
+	status = nfs4_call_sync_sequence(clnt, server, &msg,
+					&args.seq_args, &res.seq_res);
+	if (status == NFS4_OK &&
+	    res.seq_res.sr_status_flags & SEQ4_STATUS_LEASE_MOVED)
+		status = -NFS4ERR_LEASE_MOVED;
+	return status;
+}
+
+#endif	/* CONFIG_NFS_V4_1 */
+
+/**
+ * nfs4_proc_get_locations - discover locations for a migrated FSID
+ * @inode: inode on FSID that is migrating
+ * @locations: result of query
+ * @page: buffer
+ * @cred: credential to use for this operation
+ *
+ * Returns NFS4_OK on success, a negative NFS4ERR status code if the
+ * operation failed, or a negative errno if a local error occurred.
+ *
+ * On success, "locations" is filled in, but if the server has
+ * no locations information, NFS_ATTR_FATTR_V4_LOCATIONS is not
+ * asserted.
+ *
+ * -NFS4ERR_LEASE_MOVED is returned if the server still has leases
+ * from this client that require migration recovery.
+ */
+int nfs4_proc_get_locations(struct inode *inode,
+			    struct nfs4_fs_locations *locations,
+			    struct page *page, struct rpc_cred *cred)
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
+		status = ops->get_locations(inode, locations, page, cred);
+		if (status != -NFS4ERR_DELAY)
+			break;
+		nfs4_handle_exception(server, status, &exception);
+	} while (exception.retry);
+	return status;
+}
+
 /**
  * If 'use_integrity' is true and the state managment nfs_client
  * cl_rpcclient is using krb5i/p, use the integrity protected cl_rpcclient
@@ -7888,10 +8039,12 @@ static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 #endif
 
 static const struct nfs4_mig_recovery_ops nfs40_mig_recovery_ops = {
+	.get_locations = _nfs40_proc_get_locations,
 };
 
 #if defined(CONFIG_NFS_V4_1)
 static const struct nfs4_mig_recovery_ops nfs41_mig_recovery_ops = {
+	.get_locations = _nfs41_proc_get_locations,
 };
 #endif	/* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 79210d2..1854b04 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -736,13 +736,15 @@ static int nfs4_stat_to_errno(int);
 				 encode_sequence_maxsz + \
 				 encode_putfh_maxsz + \
 				 encode_lookup_maxsz + \
-				 encode_fs_locations_maxsz)
+				 encode_fs_locations_maxsz + \
+				 encode_renew_maxsz)
 #define NFS4_dec_fs_locations_sz \
 				(compound_decode_hdr_maxsz + \
 				 decode_sequence_maxsz + \
 				 decode_putfh_maxsz + \
 				 decode_lookup_maxsz + \
-				 decode_fs_locations_maxsz)
+				 decode_fs_locations_maxsz + \
+				 decode_renew_maxsz)
 #define NFS4_enc_secinfo_sz 	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
@@ -2687,11 +2689,20 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
-	encode_putfh(xdr, args->dir_fh, &hdr);
-	encode_lookup(xdr, args->name, &hdr);
-	replen = hdr.replen;	/* get the attribute into args->page */
-	encode_fs_locations(xdr, args->bitmask, &hdr);
+	if (args->migration) {
+		encode_putfh(xdr, args->fh, &hdr);
+		replen = hdr.replen;
+		encode_fs_locations(xdr, args->bitmask, &hdr);
+		if (args->renew)
+			encode_renew(xdr, args->clientid, &hdr);
+	} else {
+		encode_putfh(xdr, args->dir_fh, &hdr);
+		encode_lookup(xdr, args->name, &hdr);
+		replen = hdr.replen;
+		encode_fs_locations(xdr, args->bitmask, &hdr);
+	}
 
+	/* Set up reply kvec to capture returned fs_locations array. */
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
 			0, PAGE_SIZE);
 	encode_nops(&hdr);
@@ -6824,13 +6835,26 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_lookup(xdr);
-	if (status)
-		goto out;
-	xdr_enter_page(xdr, PAGE_SIZE);
-	status = decode_getfattr_generic(xdr, &res->fs_locations->fattr,
+	if (res->migration) {
+		xdr_enter_page(xdr, PAGE_SIZE);
+		status = decode_getfattr_generic(xdr,
+					&res->fs_locations->fattr,
 					 NULL, res->fs_locations,
 					 NULL, res->fs_locations->server);
+		if (status)
+			goto out;
+		if (res->renew)
+			status = decode_renew(xdr);
+	} else {
+		status = decode_lookup(xdr);
+		if (status)
+			goto out;
+		xdr_enter_page(xdr, PAGE_SIZE);
+		status = decode_getfattr_generic(xdr,
+					&res->fs_locations->fattr,
+					 NULL, res->fs_locations,
+					 NULL, res->fs_locations->server);
+	}
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 49f52c8..405dfad 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1053,14 +1053,18 @@ struct nfs4_fs_locations {
 struct nfs4_fs_locations_arg {
 	struct nfs4_sequence_args	seq_args;
 	const struct nfs_fh *dir_fh;
+	const struct nfs_fh *fh;
 	const struct qstr *name;
 	struct page *page;
 	const u32 *bitmask;
+	clientid4 clientid;
+	unsigned char migration:1, renew:1;
 };
 
 struct nfs4_fs_locations_res {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs4_fs_locations       *fs_locations;
+	unsigned char			migration:1, renew:1;
 };
 
 struct nfs4_secinfo4 {

