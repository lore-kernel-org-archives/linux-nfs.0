Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755057Ab0IPOYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 10:24:24 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] nfs: standardize the rename args container
Date: Thu, 16 Sep 2010 10:24:02 -0400
Message-Id: <1284647045-18286-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
References: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Each NFS version has its own version of the rename args container.
Standardize them on a common one that's identical to the one NFSv4
uses.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs2xdr.c        |    8 ++++----
 fs/nfs/nfs3proc.c       |   12 +++++-------
 fs/nfs/nfs3xdr.c        |   10 +++++-----
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/nfs4xdr.c        |    2 +-
 fs/nfs/proc.c           |   10 ++++------
 include/linux/nfs_xdr.h |   39 ++++++++++++---------------------------
 7 files changed, 32 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index db8846a..e15bc03 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -337,10 +337,10 @@ nfs_xdr_createargs(struct rpc_rqst *req, __be32 *p, struct nfs_createargs *args)
 static int
 nfs_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
 {
-	p = xdr_encode_fhandle(p, args->fromfh);
-	p = xdr_encode_array(p, args->fromname, args->fromlen);
-	p = xdr_encode_fhandle(p, args->tofh);
-	p = xdr_encode_array(p, args->toname, args->tolen);
+	p = xdr_encode_fhandle(p, args->old_dir);
+	p = xdr_encode_array(p, args->old_name->name, args->old_name->len);
+	p = xdr_encode_fhandle(p, args->new_dir);
+	p = xdr_encode_array(p, args->new_name->name, args->new_name->len);
 	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
 	return 0;
 }
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index fabb4f2..d8557b3 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -442,13 +442,11 @@ static int
 nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		 struct inode *new_dir, struct qstr *new_name)
 {
-	struct nfs3_renameargs	arg = {
-		.fromfh		= NFS_FH(old_dir),
-		.fromname	= old_name->name,
-		.fromlen	= old_name->len,
-		.tofh		= NFS_FH(new_dir),
-		.toname		= new_name->name,
-		.tolen		= new_name->len
+	struct nfs_renameargs	arg = {
+		.old_dir	= NFS_FH(old_dir),
+		.old_name	= old_name,
+		.new_dir	= NFS_FH(new_dir),
+		.new_name	= new_name,
 	};
 	struct nfs3_renameres res;
 	struct rpc_message msg = {
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 9769704..f385759 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -442,12 +442,12 @@ nfs3_xdr_mknodargs(struct rpc_rqst *req, __be32 *p, struct nfs3_mknodargs *args)
  * Encode RENAME arguments
  */
 static int
-nfs3_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs3_renameargs *args)
+nfs3_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
 {
-	p = xdr_encode_fhandle(p, args->fromfh);
-	p = xdr_encode_array(p, args->fromname, args->fromlen);
-	p = xdr_encode_fhandle(p, args->tofh);
-	p = xdr_encode_array(p, args->toname, args->tolen);
+	p = xdr_encode_fhandle(p, args->old_dir);
+	p = xdr_encode_array(p, args->old_name->name, args->old_name->len);
+	p = xdr_encode_fhandle(p, args->new_dir);
+	p = xdr_encode_array(p, args->new_name->name, args->new_name->len);
 	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
 	return 0;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 089da5b..eb36784 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2675,7 +2675,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
 	struct nfs_server *server = NFS_SERVER(old_dir);
-	struct nfs4_rename_arg arg = {
+	struct nfs_renameargs arg = {
 		.old_dir = NFS_FH(old_dir),
 		.new_dir = NFS_FH(new_dir),
 		.old_name = old_name,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 08ef912..7a098ae 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1823,7 +1823,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 /*
  * Encode RENAME request
  */
-static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs4_rename_arg *args)
+static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs_renameargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 611bec2..5c70b58 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -370,12 +370,10 @@ nfs_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
 	struct nfs_renameargs	arg = {
-		.fromfh		= NFS_FH(old_dir),
-		.fromname	= old_name->name,
-		.fromlen	= old_name->len,
-		.tofh		= NFS_FH(new_dir),
-		.toname		= new_name->name,
-		.tolen		= new_name->len
+		.old_dir	= NFS_FH(old_dir),
+		.old_name	= old_name,
+		.new_dir	= NFS_FH(new_dir),
+		.new_name	= new_name,
 	};
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_RENAME],
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index fc46192..bdda62a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -400,6 +400,18 @@ struct nfs_removeres {
 };
 
 /*
+ * Common arguments to the rename call
+ */
+struct nfs_renameargs {
+	const struct nfs_fh		*old_dir;
+	const struct nfs_fh		*new_dir;
+	const struct qstr		*old_name;
+	const struct qstr		*new_name;
+	const u32			*bitmask;
+	struct nfs4_sequence_args	seq_args;
+};
+
+/*
  * Argument struct for decode_entry function
  */
 struct nfs_entry {
@@ -434,15 +446,6 @@ struct nfs_createargs {
 	struct iattr *		sattr;
 };
 
-struct nfs_renameargs {
-	struct nfs_fh *		fromfh;
-	const char *		fromname;
-	unsigned int		fromlen;
-	struct nfs_fh *		tofh;
-	const char *		toname;
-	unsigned int		tolen;
-};
-
 struct nfs_setattrargs {
 	struct nfs_fh *                 fh;
 	nfs4_stateid                    stateid;
@@ -586,15 +589,6 @@ struct nfs3_mknodargs {
 	dev_t			rdev;
 };
 
-struct nfs3_renameargs {
-	struct nfs_fh *		fromfh;
-	const char *		fromname;
-	unsigned int		fromlen;
-	struct nfs_fh *		tofh;
-	const char *		toname;
-	unsigned int		tolen;
-};
-
 struct nfs3_linkargs {
 	struct nfs_fh *		fromfh;
 	struct nfs_fh *		tofh;
@@ -801,15 +795,6 @@ struct nfs4_readlink_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
-struct nfs4_rename_arg {
-	const struct nfs_fh *		old_dir;
-	const struct nfs_fh *		new_dir;
-	const struct qstr *		old_name;
-	const struct qstr *		new_name;
-	const u32 *			bitmask;
-	struct nfs4_sequence_args	seq_args;
-};
-
 struct nfs4_rename_res {
 	const struct nfs_server *	server;
 	struct nfs4_change_info		old_cinfo;
-- 
1.7.1

