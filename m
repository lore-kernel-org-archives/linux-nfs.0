Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755057Ab0IPOYP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 10:24:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] nfs: standardize the rename response container
Date: Thu, 16 Sep 2010 10:24:03 -0400
Message-Id: <1284647045-18286-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
References: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Right now, v3 and v4 have their own variants. Create a standard struct
that will work for v3 and v4. v2 doesn't get anything but a simple error
and so isn't affected by this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs3proc.c       |   16 ++++++++--------
 fs/nfs/nfs3xdr.c        |    6 +++---
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/nfs4xdr.c        |    2 +-
 include/linux/nfs_xdr.h |   23 +++++++++--------------
 5 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d8557b3..c5cccf1 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -448,7 +448,7 @@ nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_dir	= NFS_FH(new_dir),
 		.new_name	= new_name,
 	};
-	struct nfs3_renameres res;
+	struct nfs_renameres res;
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_RENAME],
 		.rpc_argp	= &arg,
@@ -458,17 +458,17 @@ nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 
 	dprintk("NFS call  rename %s -> %s\n", old_name->name, new_name->name);
 
-	res.fromattr = nfs_alloc_fattr();
-	res.toattr = nfs_alloc_fattr();
-	if (res.fromattr == NULL || res.toattr == NULL)
+	res.old_fattr = nfs_alloc_fattr();
+	res.new_fattr = nfs_alloc_fattr();
+	if (res.old_fattr == NULL || res.new_fattr == NULL)
 		goto out;
 
 	status = rpc_call_sync(NFS_CLIENT(old_dir), &msg, 0);
-	nfs_post_op_update_inode(old_dir, res.fromattr);
-	nfs_post_op_update_inode(new_dir, res.toattr);
+	nfs_post_op_update_inode(old_dir, res.old_fattr);
+	nfs_post_op_update_inode(new_dir, res.new_fattr);
 out:
-	nfs_free_fattr(res.toattr);
-	nfs_free_fattr(res.fromattr);
+	nfs_free_fattr(res.old_fattr);
+	nfs_free_fattr(res.new_fattr);
 	dprintk("NFS reply rename: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index f385759..89c40f8 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -970,14 +970,14 @@ nfs3_xdr_createres(struct rpc_rqst *req, __be32 *p, struct nfs3_diropres *res)
  * Decode RENAME reply
  */
 static int
-nfs3_xdr_renameres(struct rpc_rqst *req, __be32 *p, struct nfs3_renameres *res)
+nfs3_xdr_renameres(struct rpc_rqst *req, __be32 *p, struct nfs_renameres *res)
 {
 	int	status;
 
 	if ((status = ntohl(*p++)) != 0)
 		status = nfs_stat_to_errno(status);
-	p = xdr_decode_wcc_data(p, res->fromattr);
-	p = xdr_decode_wcc_data(p, res->toattr);
+	p = xdr_decode_wcc_data(p, res->old_fattr);
+	p = xdr_decode_wcc_data(p, res->new_fattr);
 	return status;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index eb36784..120a8a6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2682,7 +2682,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		.new_name = new_name,
 		.bitmask = server->attr_bitmask,
 	};
-	struct nfs4_rename_res res = {
+	struct nfs_renameres res = {
 		.server = server,
 	};
 	struct rpc_message msg = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7a098ae..b0bd7ef 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4873,7 +4873,7 @@ out:
 /*
  * Decode RENAME response
  */
-static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_rename_res *res)
+static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, __be32 *p, struct nfs_renameres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bdda62a..bfc5417 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -411,6 +411,15 @@ struct nfs_renameargs {
 	struct nfs4_sequence_args	seq_args;
 };
 
+struct nfs_renameres {
+	const struct nfs_server		*server;
+	struct nfs4_change_info		old_cinfo;
+	struct nfs_fattr		*old_fattr;
+	struct nfs4_change_info		new_cinfo;
+	struct nfs_fattr		*new_fattr;
+	struct nfs4_sequence_res	seq_res;
+};
+
 /*
  * Argument struct for decode_entry function
  */
@@ -623,11 +632,6 @@ struct nfs3_readlinkargs {
 	struct page **		pages;
 };
 
-struct nfs3_renameres {
-	struct nfs_fattr *	fromattr;
-	struct nfs_fattr *	toattr;
-};
-
 struct nfs3_linkres {
 	struct nfs_fattr *	dir_attr;
 	struct nfs_fattr *	fattr;
@@ -795,15 +799,6 @@ struct nfs4_readlink_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
-struct nfs4_rename_res {
-	const struct nfs_server *	server;
-	struct nfs4_change_info		old_cinfo;
-	struct nfs_fattr *		old_fattr;
-	struct nfs4_change_info		new_cinfo;
-	struct nfs_fattr *		new_fattr;
-	struct nfs4_sequence_res	seq_res;
-};
-
 #define NFS4_SETCLIENTID_NAMELEN	(127)
 struct nfs4_setclientid {
 	const nfs4_verifier *		sc_verifier;
-- 
1.7.1

