Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34028 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbbICRdV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2015 13:33:21 -0400
Received: by qgez77 with SMTP id z77so34556633qge.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2015 10:33:21 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: add a new nowcc export option to disable WCC attrs in v3 replies
Date: Thu,  3 Sep 2015 13:33:14 -0400
Message-Id: <1441301594-17293-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are cases with NFSv3 where the client doesn't actually care about
WCC attributes in replies. If the server is mainly acting as a DS for
flexfiles, then the client just throws out those attributes anyway.
Also, in the case where the client is primarily doing direct I/O, post
op attributes aren't terribly useful

Another reason to allow turning these off is that NFS will flush all
buffered writes prior to issuing a GETATTR, and it also takes the
i_mutex in its ->getattr operation.

If we're doing a vfs_getattr after most RPCs, then we can end up
deadlocking or (at best) prematurely flushing buffered writes, which
kills performance.

This patch adds a new export option -- "nowcc" that disables the return
of WCC attributes in NFSv3 replies. I also have a userland patch that
adds support for the same option to nfs-utils that I'll send along as
well.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/export.c                 | 1 +
 fs/nfsd/nfs3xdr.c                | 5 ++++-
 fs/nfsd/nfsfh.c                  | 4 ++++
 fs/nfsd/nfsfh.h                  | 5 ++++-
 include/uapi/linux/nfsd/export.h | 3 ++-
 5 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b4d84b579f20..97258009ce1e 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1092,6 +1092,7 @@ static struct flags {
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 	{ NFSEXP_V4ROOT, {"v4root", ""}},
 	{ NFSEXP_PNFS, {"pnfs", ""}},
+	{ NFSEXP_NOWCC, {"nowcc", ""}},
 	{ 0, {"", ""}}
 };
 
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 01dcd494f781..c30c8c604e2a 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -203,7 +203,7 @@ static __be32 *
 encode_post_op_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 {
 	struct dentry *dentry = fhp->fh_dentry;
-	if (dentry && d_really_is_positive(dentry)) {
+	if (!fhp->fh_no_wcc && dentry && d_really_is_positive(dentry)) {
 	        __be32 err;
 		struct kstat stat;
 
@@ -256,6 +256,9 @@ void fill_post_wcc(struct svc_fh *fhp)
 {
 	__be32 err;
 
+	if (fhp->fh_no_wcc)
+		return;
+
 	if (fhp->fh_post_saved)
 		printk("nfsd: inode locked twice during operation.\n");
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 350041a40fe5..32093b7dce55 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -267,6 +267,9 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 
 	fhp->fh_dentry = dentry;
 	fhp->fh_export = exp;
+	if (exp->ex_flags & NFSEXP_NOWCC && rqstp->rq_vers == 3)
+		fhp->fh_no_wcc = true;
+
 	return 0;
 out:
 	exp_put(exp);
@@ -641,6 +644,7 @@ fh_put(struct svc_fh *fhp)
 		exp_put(exp);
 		fhp->fh_export = NULL;
 	}
+	fhp->fh_no_wcc = false;
 	return;
 }
 
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 1e90dad4926b..9ddead4d98f8 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -32,6 +32,7 @@ typedef struct svc_fh {
 
 	unsigned char		fh_locked;	/* inode locked by us */
 	unsigned char		fh_want_write;	/* remount protection taken */
+	bool			fh_no_wcc;	/* no wcc data needed */
 
 #ifdef CONFIG_NFSD_V3
 	unsigned char		fh_post_saved;	/* post-op attrs saved */
@@ -51,7 +52,6 @@ typedef struct svc_fh {
 	struct kstat		fh_post_attr;	/* full attrs after operation */
 	u64			fh_post_change; /* nfsv4 change; see above */
 #endif /* CONFIG_NFSD_V3 */
-
 } svc_fh;
 
 enum nfsd_fsid {
@@ -225,6 +225,9 @@ fill_pre_wcc(struct svc_fh *fhp)
 {
 	struct inode    *inode;
 
+	if (fhp->fh_no_wcc)
+		return;
+
 	inode = d_inode(fhp->fh_dentry);
 	if (!fhp->fh_pre_saved) {
 		fhp->fh_pre_mtime = inode->i_mtime;
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index 0df7bd5d2fb1..4c132290f414 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -51,9 +51,10 @@
  */
 #define	NFSEXP_V4ROOT		0x10000
 #define NFSEXP_PNFS		0x20000
+#define NFSEXP_NOWCC		0x40000
 
 /* All flags that we claim to support.  (Note we don't support NOACL.) */
-#define NFSEXP_ALLFLAGS		0x3FE7F
+#define NFSEXP_ALLFLAGS		0x7FE7F
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
-- 
2.4.3

