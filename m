Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41109 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537AbcETOo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 May 2016 10:44:27 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 07/10] NFS probe pseudo-fs for replicas
Date: Fri, 20 May 2016 10:43:54 -0400
Message-ID: <1463755437-17649-8-git-send-email-andros@netapp.com>
In-Reply-To: <1463755437-17649-1-git-send-email-andros@netapp.com>
References: <1463755437-17649-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Probe an NFSv4 Pseudo-fs for fs_locations replicas. Replicas on a Pseudo-fs
returns multipath addresses for the server which will be tested
for session trunking.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h       |  2 ++
 fs/nfs/nfs4getroot.c    |  3 ++
 fs/nfs/nfs4proc.c       | 82 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        | 38 +++++++++--------------
 include/linux/nfs_xdr.h |  4 +--
 5 files changed, 104 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f1d1d2c..4a65288 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -528,6 +528,8 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
+extern void nfs4_get_pseudofs_replicas(struct nfs_server *server,
+				struct nfs_fh *mntfh);
 
 static inline struct inode *nfs_igrab_and_active(struct inode *inode)
 {
diff --git a/fs/nfs/nfs4getroot.c b/fs/nfs/nfs4getroot.c
index 039b3eb..4c1f5e4 100644
--- a/fs/nfs/nfs4getroot.c
+++ b/fs/nfs/nfs4getroot.c
@@ -36,6 +36,9 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool auth_p
 	}
 
 	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
+
+	nfs4_get_pseudofs_replicas(server, mntfh);
+
 out:
 	nfs_free_fattr(fsinfo.fattr);
 	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 70537f0..7b7944a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3253,6 +3253,88 @@ static int nfs4_do_find_root_sec(struct nfs_server *server,
 	return nfs_v4_minor_ops[mv]->find_root_sec(server, fhandle, info);
 }
 
+static int _nfs4_proc_fs_locations_probe(struct nfs_server *server,
+					 struct nfs_fh *fhandle,
+					 struct nfs4_fs_locations *fs_locations,
+					 struct page *page)
+{
+	u32 bitmask[3] = {
+		[0] = FATTR4_WORD0_FS_LOCATIONS,
+	};
+	struct nfs4_fs_locations_arg args = {
+		.fh = fhandle,
+		.page = page,
+		.bitmask = bitmask,
+		.replicas = 1,
+	};
+	struct nfs4_fs_locations_res res = {
+		.fs_locations = fs_locations,
+		.replicas = 1,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	struct rpc_clnt *clnt = server->nfs_client->cl_rpcclient;
+
+	nfs_fattr_init(&fs_locations->fattr);
+	fs_locations->nlocations = 0;
+	fs_locations->server = server;
+	return nfs4_call_sync(clnt, server, &msg, &args.seq_args,
+				&res.seq_res, 0);
+}
+
+static int nfs4_proc_fs_locations_probe(struct nfs_server *server,
+					struct nfs_fh *fhandle,
+					struct nfs4_fs_locations *fs_locations,
+					struct page *page)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = _nfs4_proc_fs_locations_probe(server, fhandle,
+						fs_locations, page);
+		err = nfs4_handle_exception(server, err, &exception);
+	} while (exception.retry);
+	return err;
+}
+
+
+/**
+ * Probe the pseudo filesystem for an fs_locations replicas list.
+ * Note: The replicas list on a pseudofs is a list of multipath
+ * addresses
+ */
+void nfs4_get_pseudofs_replicas(struct nfs_server *server,
+				       struct nfs_fh *mntfh)
+{
+	struct page *page = NULL;
+	struct nfs4_fs_locations *locations = NULL;
+	int status;
+
+	if (server->nfs_client->cl_minorversion == 0)
+		return;
+
+	page = alloc_page(GFP_KERNEL);
+	if (page == NULL)
+		goto out;
+	locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
+	if (locations == NULL)
+		goto out;
+
+	status = nfs4_proc_fs_locations_probe(server, mntfh, locations, page);
+	if (status != 0)
+		goto out;
+
+	/* test replicas for session trunking here */
+out:
+	if (page)
+		__free_page(page);
+	kfree(locations);
+}
+
 /**
  * nfs4_proc_get_rootfh - get file handle for server's pseudoroot
  * @server: initialized nfs_server handle
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 88474a4..3d06c32 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2685,18 +2685,17 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
-	if (args->migration) {
+	if (args->replicas || args->migration) {
 		encode_putfh(xdr, args->fh, &hdr);
-		replen = hdr.replen;
-		encode_fs_locations(xdr, args->bitmask, &hdr);
-		if (args->renew)
-			encode_renew(xdr, args->clientid, &hdr);
 	} else {
 		encode_putfh(xdr, args->dir_fh, &hdr);
 		encode_lookup(xdr, args->name, &hdr);
-		replen = hdr.replen;
-		encode_fs_locations(xdr, args->bitmask, &hdr);
 	}
+	replen = hdr.replen;
+	encode_fs_locations(xdr, args->bitmask, &hdr);
+
+	if(args->migration && args->renew)
+		encode_renew(xdr, args->clientid, &hdr);
 
 	/* Set up reply kvec to capture returned fs_locations array. */
 	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
@@ -6916,26 +6915,19 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	if (res->migration) {
-		xdr_enter_page(xdr, PAGE_SIZE);
-		status = decode_getfattr_generic(xdr,
-					&res->fs_locations->fattr,
-					 NULL, res->fs_locations,
-					 NULL, res->fs_locations->server);
-		if (status)
-			goto out;
-		if (res->renew)
-			status = decode_renew(xdr);
-	} else {
+	if (!res->replicas && !res->migration) {
 		status = decode_lookup(xdr);
 		if (status)
 			goto out;
-		xdr_enter_page(xdr, PAGE_SIZE);
-		status = decode_getfattr_generic(xdr,
-					&res->fs_locations->fattr,
-					 NULL, res->fs_locations,
-					 NULL, res->fs_locations->server);
 	}
+	xdr_enter_page(xdr, PAGE_SIZE);
+	status = decode_getfattr_generic(xdr,
+				&res->fs_locations->fattr,
+				NULL, res->fs_locations,
+				NULL, res->fs_locations->server);
+	if (res->migration && res->renew && !status)
+		status = decode_renew(xdr);
+
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d320906..ab9a08a2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1120,13 +1120,13 @@ struct nfs4_fs_locations_arg {
 	struct page *page;
 	const u32 *bitmask;
 	clientid4 clientid;
-	unsigned char migration:1, renew:1;
+	unsigned char migration:1, renew:1, replicas:1;
 };
 
 struct nfs4_fs_locations_res {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs4_fs_locations       *fs_locations;
-	unsigned char			migration:1, renew:1;
+	unsigned char			migration:1, renew:1, replicas:1;
 };
 
 struct nfs4_secinfo4 {
-- 
1.8.3.1

