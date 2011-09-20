Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086Ab1ITSxV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 14:53:21 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1R65RZ-00043m-19
	for linux-nfs@vger.kernel.org; Tue, 20 Sep 2011 14:53:21 -0400
Date: Tue, 20 Sep 2011 14:53:20 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: make op_cacheresult another flag
Message-ID: <20110920185320.GB15273@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Also for 3.2.

--b.

commit c856694e3d46976c76bf5b92091cb1efa211208d
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Sep 20 08:49:51 2011 -0400

    nfsd4: make op_cacheresult another flag
    
    I'm not sure why I used a new field for this originally.
    
    Also, the differences between some of these flags are a little subtle;
    add some comments to explain.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index aa769df..4e41f65 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1013,14 +1013,15 @@ enum nfsd4_op_flags {
 	/* For rfc 5661 section 2.6.3.1.1: */
 	OP_HANDLES_WRONGSEC = 1 << 3,
 	OP_IS_PUTFH_LIKE = 1 << 4,
-	OP_MODIFIES_SOMETHING = 1 << 5, /* op is non-idempotent */
-};
-
-struct nfsd4_operation {
-	nfsd4op_func op_func;
-	u32 op_flags;
-	char *op_name;
 	/*
+	 * These are the ops whose result size we estimate before
+	 * encoding, to avoid performing an op then not being able to
+	 * respond or cache a response.  This includes writes and setattrs
+	 * as well as the operations usually called "nonidempotent":
+	 */
+	OP_MODIFIES_SOMETHING = 1 << 5,
+	/*
+	 * Cache compounds containing these ops in the xid-based drc:
 	 * We use the DRC for compounds containing non-idempotent
 	 * operations, *except* those that are 4.1-specific (since
 	 * sessions provide their own EOS), and except for stateful
@@ -1028,7 +1029,13 @@ struct nfsd4_operation {
 	 * (since sequence numbers provide EOS for open, lock, etc in
 	 * the v4.0 case).
 	 */
-	bool op_cacheresult;
+	OP_CACHEME = 1 << 6,
+};
+
+struct nfsd4_operation {
+	nfsd4op_func op_func;
+	u32 op_flags;
+	char *op_name;
 	/* Try to get response size before operation */
 	nfsd4op_rsize op_rsize_bop;
 };
@@ -1077,7 +1084,7 @@ static inline struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
 
 bool nfsd4_cache_this_op(struct nfsd4_op *op)
 {
-	return OPDESC(op)->op_cacheresult;
+	return OPDESC(op)->op_flags & OP_CACHEME;
 }
 
 static bool need_wrongsec_check(struct svc_rqst *rqstp)
@@ -1420,9 +1427,8 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_CREATE] = {
 		.op_func = (nfsd4op_func)nfsd4_create,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_CREATE",
-		.op_cacheresult = true,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_create_rsize,
 	},
 	[OP_DELEGRETURN] = {
@@ -1442,9 +1448,9 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LINK] = {
 		.op_func = (nfsd4op_func)nfsd4_link,
-		.op_flags = ALLOWED_ON_ABSENT_FS | OP_MODIFIES_SOMETHING,
+		.op_flags = ALLOWED_ON_ABSENT_FS | OP_MODIFIES_SOMETHING
+				| OP_CACHEME,
 		.op_name = "OP_LINK",
-		.op_cacheresult = true,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_link_rsize,
 	},
 	[OP_LOCK] = {
@@ -1534,16 +1540,14 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_REMOVE] = {
 		.op_func = (nfsd4op_func)nfsd4_remove,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_REMOVE",
-		.op_cacheresult = true,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_remove_rsize,
 	},
 	[OP_RENAME] = {
 		.op_func = (nfsd4op_func)nfsd4_rename,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_RENAME",
-		.op_cacheresult = true,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_rename_rsize,
 	},
 	[OP_RENEW] = {
@@ -1575,24 +1579,21 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_SETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_setattr,
 		.op_name = "OP_SETATTR",
-		.op_flags = OP_MODIFIES_SOMETHING,
-		.op_cacheresult = true,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setattr_rsize,
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_MODIFIES_SOMETHING,
+				| OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_SETCLIENTID",
-		.op_cacheresult = true,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setclientid_rsize,
 	},
 	[OP_SETCLIENTID_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid_confirm,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_MODIFIES_SOMETHING,
+				| OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_SETCLIENTID_CONFIRM",
-		.op_cacheresult = true,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_VERIFY] = {
@@ -1601,9 +1602,8 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_WRITE] = {
 		.op_func = (nfsd4op_func)nfsd4_write,
-		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_WRITE",
-		.op_cacheresult = true,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
