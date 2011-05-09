Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:52826 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab1EIThr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:37:47 -0400
Received: by yxs7 with SMTP id 7so1914783yxs.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:37:46 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/16] NFS: Introduce nfs4_proc_get_mig_status()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:37:43 -0400
Message-ID: <20110509193743.16568.57659.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The nfs4_proc_fs_locations() function is invoked during referral
processing to perform a GETATTR(fs_locations) on an object's parent
directory in order to discover the target of the referral.  It
performs a LOOKUP, so the client needs to know the parent's file
handle a priori.

  o During migration recovery, we need to probe fs_locations informa-
    tion on an FSID's root directory.  The "parent" of a root
    directory is not available for a LOOKUP operation.

  o Recovering from NFS4ERR_LEASE_MOVED is a process of walking over a
    list of known FSIDs that reside on the server, and probing whether
    they have migrated.  Once the server has detected that the client
    has probed all migrated file systems, it stops returning
    NFS4ERR_LEASE_MOVED.

    A minor version zero server needs to know what client ID is
    requesting fs_locations information so it can clear the flag that
    forces it to continue returning NFS4ERR_LEASE_MOVED.  This flag is
    set per client ID and per FSID.  However, the client ID is not an
    argument of either the PUTFH or GETATTR operations.  Later minor
    versions have client ID information embedded in the underlying
    session.

    Therefore, by convention, minor version zero clients send a RENEW
    operation in the same compound as the GETATTR(fs_locations), since
    RENEW has one argument: the short-form client ID.  This allows a
    minor version zero server to identify correctly the client that is
    probing for a migration.

  o For various subtle reasons, servers can't return NFS4ERR_DELAY to
    state-changing operations while they are actually doing the
    migration.  Instead, they put off clients during the brief window
    when the data is actually unavailable by returning DELAY to the
    GETATTR(fs_locations), since GETATTR doesn't mutate NFSv4 state.
    So our client must be able to deal properly with an NFS4ERR_DELAY
    reply during a migration status probe.

To handle all this random wackiness, we need a variant of
nfs4_proc_fs_locations() that can operate directly on a target file
handle, rather than taking a name and doing a LOOKUP as part of
retrieving fs_locations from the server.  It also must properly append
a RENEW operation as needed, and it should retry NFS4ERR_DELAY as
appropriate.

Introduce nfs4_proc_get_mig_status() to fill this role, and add the
requisite XDR encoding and decoding paraphenalia.  Under the covers,
both nfs4_proc_foo functions use the FS_LOCATIONS XDR routines.  This
is a little awkward, but is necessary because it's currently not
straightforward to add new NFSv4 procedures due to a bug in nfsstat.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h        |    2 +
 fs/nfs/nfs4proc.c       |   89 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c        |   48 ++++++++++++++++++-------
 include/linux/nfs_xdr.h |    7 +++-
 4 files changed, 130 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c4a6983..4038c5b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -242,6 +242,8 @@ extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_proc_get_mig_status(struct nfs_server *server,
+		struct nfs4_fs_locations *fs_locations, struct page *page);
 extern void nfs4_release_lockowner(const struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 641691c..57b7279 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4666,6 +4666,16 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 	fattr->nlink = 2;
 }
 
+/**
+ * nfs4_proc_fs_locations - retrieve locations array for a named object
+ *
+ * @dir: inode of parent directory
+ * @name: qstr containing name of object to query
+ * @locations: result of query
+ * @page: buffer
+ *
+ * Returns zero on success, or a negative errno code
+ */
 int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page)
 {
@@ -4690,16 +4700,91 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	};
 	int status;
 
-	dprintk("%s: start\n", __func__);
+	dprintk("--> %s: FSID %llx:%llx on \"%s\"\n", __func__,
+		(unsigned long long)server->fsid.major,
+		(unsigned long long)server->fsid.minor,
+		server->nfs_client->cl_hostname);
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	nfs_fixup_referral_attributes(&fs_locations->fattr);
-	dprintk("%s: returned status = %d\n", __func__, status);
+	dprintk("<-- %s status=%d\n", __func__, status);
+	return status;
+}
+
+static int _nfs4_proc_get_mig_status(struct nfs_server *server,
+				     struct nfs4_fs_locations *locations,
+				     struct page *page)
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
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
+		.rpc_argp	= &args,
+		.rpc_resp	= &res,
+	};
+	int status;
+
+	dprintk("--> %s: FSID %llx:%llx on \"%s\"\n", __func__,
+		(unsigned long long)server->fsid.major,
+		(unsigned long long)server->fsid.minor,
+		args.client->cl_hostname);
+	nfs_display_fhandle(args.fh, "Probing file handle");
+
+	args.mig_status = res.mig_status = 1;
+	if (args.client->cl_mvops->minor_version == 0)
+		args.renew = res.renew = 1;
+	nfs_fattr_init(&locations->fattr);
+	locations->server = server;
+	locations->nlocations = 0;
+	status = nfs4_call_sync(server->client, server, &msg,
+					&args.seq_args, &res.seq_res, 0);
+	dprintk("<-- %s status=%d\n", __func__, status);
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
+ *
+ * Servers often return NFS4ERR_DELAY to our migration probe while a
+ * migration is in progress.  This allows a server to delay client
+ * activity without returning NFS4ERR_DELAY on a sequence ID mutating
+ * operation.
+ */
+int nfs4_proc_get_mig_status(struct nfs_server *server,
+			     struct nfs4_fs_locations *locations,
+			     struct page *page)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = _nfs4_proc_get_mig_status(server, locations, page);
+		if (err != -NFS4ERR_DELAY)
+			break;
+		nfs4_handle_exception(server, err, &exception);
+	} while (exception.retry);
+	return err;
+}
+
 static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
 {
 	int status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index be70be9..efb6094 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -684,13 +684,15 @@ static int nfs4_stat_to_errno(int);
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
+				 encode_renew_maxsz)
 #define NFS4_enc_secinfo_sz 	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
@@ -2529,11 +2531,20 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
-	encode_putfh(xdr, args->dir_fh, &hdr);
-	encode_lookup(xdr, args->name, &hdr);
-	replen = hdr.replen;	/* get the attribute into args->page */
-	encode_fs_locations(xdr, args->bitmask, &hdr);
+	if (args->mig_status) {
+		encode_putfh(xdr, args->fh, &hdr);
+		replen = hdr.replen;
+		encode_fs_locations(xdr, args->bitmask, &hdr);
+		if (args->renew)
+			encode_renew(xdr, args->client, &hdr);
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
@@ -6134,13 +6145,24 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_lookup(xdr);
-	if (status)
-		goto out;
-	xdr_enter_page(xdr, PAGE_SIZE);
-	status = decode_getfattr(xdr, &res->fs_locations->fattr,
-				 res->fs_locations->server,
-				 !RPC_IS_ASYNC(req->rq_task));
+	if (res->mig_status) {
+		xdr_enter_page(xdr, PAGE_SIZE);
+		status = decode_getfattr(xdr, &res->fs_locations->fattr,
+					res->fs_locations->server,
+					!RPC_IS_ASYNC(req->rq_task));
+		if (status)
+			goto out;
+		if (res->renew)
+			status = decode_renew(xdr);
+	} else {
+		status = decode_lookup(xdr);
+		if (status)
+			goto out;
+		xdr_enter_page(xdr, PAGE_SIZE);
+		status = decode_getfattr(xdr, &res->fs_locations->fattr,
+					res->fs_locations->server,
+					!RPC_IS_ASYNC(req->rq_task));
+	}
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 26165a5..22e34d3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -957,16 +957,21 @@ struct nfs4_fs_locations {
 };
 
 struct nfs4_fs_locations_arg {
+	const struct nfs_client *client;
 	const struct nfs_fh *dir_fh;
+	const struct nfs_fh *fh;
 	const struct qstr *name;
 	struct page *page;
 	const u32 *bitmask;
-	struct nfs4_sequence_args	seq_args;
+	struct nfs4_sequence_args seq_args;
+	unsigned char mig_status:1, renew:1;
 };
 
 struct nfs4_fs_locations_res {
 	struct nfs4_fs_locations       *fs_locations;
 	struct nfs4_sequence_res	seq_res;
+	unsigned char			mig_status:1,
+					renew:1;
 };
 
 struct nfs4_secinfo_oid {

