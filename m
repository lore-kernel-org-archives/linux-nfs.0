Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754174Ab0IJT1U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Sep 2010 15:27:20 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRK2Y014773
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:20 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o8AJRIBS018810
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:27:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] nfs: eliminate nfs3_renameargs
Date: Fri, 10 Sep 2010 15:27:10 -0400
Message-Id: <1284146838-1468-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284146838-1468-1-git-send-email-jlayton@redhat.com>
References: <1284146838-1468-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It's exactly the same as nfs_renameargs, so move it to the area of the
header where protocol-neutral defintions live and eliminate the v3
specific variant.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs3proc.c       |    2 +-
 fs/nfs/nfs3xdr.c        |    2 +-
 include/linux/nfs_xdr.h |   30 ++++++++++++------------------
 3 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index fabb4f2..b53b1a9 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -442,7 +442,7 @@ static int
 nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		 struct inode *new_dir, struct qstr *new_name)
 {
-	struct nfs3_renameargs	arg = {
+	struct nfs_renameargs	arg = {
 		.fromfh		= NFS_FH(old_dir),
 		.fromname	= old_name->name,
 		.fromlen	= old_name->len,
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 9769704..d6506f8 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -442,7 +442,7 @@ nfs3_xdr_mknodargs(struct rpc_rqst *req, __be32 *p, struct nfs3_mknodargs *args)
  * Encode RENAME arguments
  */
 static int
-nfs3_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs3_renameargs *args)
+nfs3_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
 {
 	p = xdr_encode_fhandle(p, args->fromfh);
 	p = xdr_encode_array(p, args->fromname, args->fromlen);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index fc46192..c606f60 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -400,6 +400,18 @@ struct nfs_removeres {
 };
 
 /*
+ * Common arguments to the rename call
+ */
+struct nfs_renameargs {
+	struct nfs_fh *		fromfh;
+	const char *		fromname;
+	unsigned int		fromlen;
+	struct nfs_fh *		tofh;
+	const char *		toname;
+	unsigned int		tolen;
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
-- 
1.7.1

