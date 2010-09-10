Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453Ab0IJT1U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Sep 2010 15:27:20 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRKrM023570
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:20 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRIBT018810
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:20 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] nfs: convert nfs_renameargs to use qstr structs
Date: Fri, 10 Sep 2010 15:27:11 -0400
Message-Id: <1284146838-1468-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284146838-1468-1-git-send-email-jlayton@redhat.com>
References: <1284146838-1468-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The v4 version already does this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs2xdr.c        |    8 ++++----
 fs/nfs/nfs3proc.c       |   10 ++++------
 fs/nfs/nfs3xdr.c        |    8 ++++----
 fs/nfs/proc.c           |   10 ++++------
 include/linux/nfs_xdr.h |   10 ++++------
 5 files changed, 20 insertions(+), 26 deletions(-)

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
index b53b1a9..d8557b3 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -443,12 +443,10 @@ nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
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
 	struct nfs3_renameres res;
 	struct rpc_message msg = {
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d6506f8..f385759 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -444,10 +444,10 @@ nfs3_xdr_mknodargs(struct rpc_rqst *req, __be32 *p, struct nfs3_mknodargs *args)
 static int
 nfs3_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
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
index c606f60..5436680 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -403,12 +403,10 @@ struct nfs_removeres {
  * Common arguments to the rename call
  */
 struct nfs_renameargs {
-	struct nfs_fh *		fromfh;
-	const char *		fromname;
-	unsigned int		fromlen;
-	struct nfs_fh *		tofh;
-	const char *		toname;
-	unsigned int		tolen;
+	const struct nfs_fh *	old_dir;
+	const struct nfs_fh *	new_dir;
+	const struct qstr *	old_name;
+	const struct qstr *	new_name;
 };
 
 /*
-- 
1.7.1

