Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56623 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab1CJRaC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:30:02 -0500
Received: by mail-iw0-f174.google.com with SMTP id 34so1743856iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2011 09:30:01 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] NFS: Introduce nfs4_proc_get_mig_status()
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Mar 2011 12:29:59 -0500
Message-ID: <20110310172959.8878.88948.stgit@matisse.1015granger.net>
In-Reply-To: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The nfs4_proc_fs_locations() function is invoked during referral
processing to perform a GETATTR(fs_locations) on an object's parent
directory in order to discover the target of the referral.  It
performs a LOOKUP, so the client needs to know the parent's file
handle a priori.

During a migration event, an NFS4ERR_MOVED can be returned to some
client contexts that don't have the parent file handle readily
available.  For example, suppose the proc function handling the
reply doesn't have a pointer to the object's dentry.  In such cases,
all we have is the file handle of the object that got the error.

Or, we may need to probe fs_locations information on a root directory.
In that case, the "parent" of the root may not make sense.

Finally, a minor version zero server needs to know what client ID is
requesting fs_locations information, so it can clear the flag that
forces it to continue returning NFS4ERR_LEASE_MOVED.  This flag is set
per client ID and per FSID.  The client ID is not an argument of the
PUTFH or GETATTR operations.

Later minor versions have client ID information embedded in the
session ID.  By convention, minor version zero clients send a RENEW
operation in the same compound as the GETATTR(fs_locations).  (We may
need to visit this for referrals too, in case the LOOKUP operation is
actually seeing a migration).

Because of all of this, we need a new variant of
nfs4_proc_fs_locations() that can operate directly on a target file
handle, rather than taking a name and doing a LOOKUP as part of
retrieving fs_locations from the server.  It also must properly append
a RENEW operation as needed.  Introduce nfs4_proc_get_mig_status() to
fill this role, and add the requisite XDR encoding and decoding
paraphenalia.

Our client now has two ways to retrieve fs_locations data.  This means
that the name of the ATTR flag that indicates the presence of
fs_locations data, NFS_ATTR_FATTR_V4_REFERRAL, no longer aligns with
the flag's usage.  Introduce a new flag for indicating only that
fs_locations data is present.  Keep the NFS_ATTR_FATTR_V4_REFERRAL
flag for indicating additionally that, in fact, a referral has
occurred.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h        |    2 +
 fs/nfs/nfs4proc.c       |   54 ++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c        |   81 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |    7 +++-
 5 files changed, 141 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7a74740..253156e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -240,6 +240,8 @@ extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_proc_get_mig_status(struct nfs_server *server,
+		struct nfs4_fs_locations *fs_locations, struct page *page);
 extern void nfs4_release_lockowner(const struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 491b068..403d257 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2202,7 +2202,8 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 	}
 
 	memcpy(fattr, &locations->fattr, sizeof(struct nfs_fattr));
-	fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
+	if (fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)
+		fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
 	if (!fattr->mode)
 		fattr->mode = S_IFDIR;
 	memset(fhandle, 0, sizeof(struct nfs_fh));
@@ -4517,7 +4518,7 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 {
 	if (!((fattr->valid & NFS_ATTR_FATTR_FILEID) &&
 		(fattr->valid & NFS_ATTR_FATTR_FSID) &&
-		(fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
+		(fattr->valid & NFS_ATTR_FATTR_V4_LOCATIONS)))
 		return;
 
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
@@ -4560,6 +4561,55 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	return status;
 }
 
+/**
+ * nfs4_proc_get_mig_status - probe migration status of an export
+ *
+ * @server: local state for server
+ * @locations: result of query
+ * @page: buffer
+ *
+ * Returns zero on success, or a negative errno code
+ */
+int nfs4_proc_get_mig_status(struct nfs_server *server,
+			     struct nfs4_fs_locations *locations,
+			     struct page *page)
+{
+	u32 bitmask[2] = {
+		[0]		= FATTR4_WORD0_FSID |
+				  FATTR4_WORD0_FS_LOCATIONS,
+	};
+	struct nfs4_fs_locations_arg args = {
+		.client		= server->nfs_client,
+		.fh		= server->rootfh,
+		.page		= page,
+		.bitmask	= bitmask,
+	};
+	struct nfs4_fs_locations_res res = {
+		.fs_locations	= locations,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_GET_MIG_STATUS],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+	int status;
+
+	dprintk("--> %s: FSID %llx:%llx on \"%s\"\n", __func__,
+		(unsigned long long)server->fsid.major,
+		(unsigned long long)server->fsid.minor,
+		args.client->cl_hostname);
+	nfs_display_fhandle(args.fh);
+
+	if (args.client->cl_mvops->minor_version == 0)
+		args.renew = res.renew = 1;
+	nfs_fattr_init(&locations->fattr);
+	locations->server = server;
+	locations->nlocations = 0;
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	dprintk("<-- %s status=%d\n", __func__, status);
+	return status;
+}
+
 #ifdef CONFIG_NFS_V4_1
 /*
  * Check the exchange flags returned by the server for invalid flags, having
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e2c168..a39e17f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -676,6 +676,18 @@ static int nfs4_stat_to_errno(int);
 				 decode_putfh_maxsz + \
 				 decode_lookup_maxsz + \
 				 decode_fs_locations_maxsz)
+#define NFS4_enc_get_mig_status_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_sequence_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_fs_locations_maxsz + \
+				 encode_renew_maxsz)
+#define NFS4_dec_get_mig_status_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_sequence_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_fs_locations_maxsz + \
+				 encode_renew_maxsz)
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_enc_exchange_id_sz \
 				(compound_encode_hdr_maxsz + \
@@ -2460,6 +2472,41 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 	encode_nops(&hdr);
 }
 
+/*
+ * Encode migration status probe
+ */
+static int nfs4_xdr_enc_get_mig_status(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       struct nfs4_fs_locations_arg *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+	uint32_t replen;
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, args->fh, &hdr);
+	replen = hdr.replen;	/* get the attribute into args->page */
+	encode_fs_locations(xdr, args->bitmask, &hdr);
+
+	/* Minor version zero servers need to have a client ID
+	 * associated with this GETATTR(fs_locations) operation,
+	 * to clear the "keep returning LEASE_MOVED" flag for
+	 * this client ID.  By convention, a RENEW operation is
+	 * appended to the GETATTR(fs_locations) compound, as
+	 * RENEW takes a client ID argument.  Later minor
+	 * versions get the client ID from the session. */
+	if (args->renew)
+		encode_renew(xdr, args->client, &hdr);
+
+	/* Set up reply kvec to capture returned fs_locations array. */
+	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
+			0, PAGE_SIZE);
+	encode_nops(&hdr);
+	return 0;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 /*
  * EXCHANGE_ID request
@@ -3204,7 +3251,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			res->nlocations++;
 	}
 	if (res->nlocations != 0)
-		status = NFS_ATTR_FATTR_V4_REFERRAL;
+		status = NFS_ATTR_FATTR_V4_LOCATIONS;
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
@@ -5915,6 +5962,37 @@ out:
 	return status;
 }
 
+/*
+ * Decode migration status probe
+ */
+static int nfs4_xdr_dec_get_mig_status(struct rpc_rqst *req,
+				       struct xdr_stream *xdr,
+				       struct nfs4_fs_locations_res *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, req);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	xdr_enter_page(xdr, PAGE_SIZE);
+	status = decode_getfattr(xdr, &res->fs_locations->fattr,
+				 res->fs_locations->server,
+				 !RPC_IS_ASYNC(req->rq_task));
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
  * Decode EXCHANGE_ID response
@@ -6255,6 +6333,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(GETACL,		enc_getacl,		dec_getacl),
 	PROC(SETACL,		enc_setacl,		dec_setacl),
 	PROC(FS_LOCATIONS,	enc_fs_locations,	dec_fs_locations),
+	PROC(GET_MIG_STATUS,	enc_get_mig_status,	dec_get_mig_status),
 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
 #if defined(CONFIG_NFS_V4_1)
 	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 134716e..02a10df 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -549,6 +549,7 @@ enum {
 	NFSPROC4_CLNT_GETACL,
 	NFSPROC4_CLNT_SETACL,
 	NFSPROC4_CLNT_FS_LOCATIONS,
+	NFSPROC4_CLNT_GET_MIG_STATUS,
 	NFSPROC4_CLNT_RELEASE_LOCKOWNER,
 
 	/* nfs41 */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b006857..632e869 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -77,7 +77,8 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_PRECTIME		(1U << 16)
 #define NFS_ATTR_FATTR_CHANGE		(1U << 17)
 #define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
-#define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
+#define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)
+#define NFS_ATTR_FATTR_V4_LOCATIONS	(1U << 20)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -924,14 +925,18 @@ struct nfs4_fs_locations {
 };
 
 struct nfs4_fs_locations_arg {
+	const struct nfs_client *client;
 	const struct nfs_fh *dir_fh;
+	const struct nfs_fh *fh;
 	const struct qstr *name;
 	struct page *page;
 	const u32 *bitmask;
+	int renew;
 	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_fs_locations_res {
+	int				renew;
 	struct nfs4_fs_locations       *fs_locations;
 	struct nfs4_sequence_res	seq_res;
 };

