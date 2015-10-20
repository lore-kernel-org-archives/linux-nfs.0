Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:34226 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047AbbJTReJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:09 -0400
Received: by qgem9 with SMTP id m9so21701930qge.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:08 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 11/19] nfsd: allow filecache open to skip fh_verify check
Date: Tue, 20 Oct 2015 13:33:44 -0400
Message-Id: <1445362432-18869-12-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we call fh_verify twice on the filehandle. Once when we call
into nfsd_file_acquire, and then again from nfsd_open. The second one is
completely superfluous though, and fh_verify can do some things that
require a fair bit of work (checking permissions, for instance).

Create a new nfsd_open_verified function that will do an nfsd_open on a
filehandle that has already been verified. Call that from the filecache
code.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c |  3 ++-
 fs/nfsd/vfs.c       | 63 +++++++++++++++++++++++++++++++++++------------------
 fs/nfsd/vfs.h       |  2 ++
 3 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index aca3c3c638ec..3a4e423d2bb9 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -670,7 +670,8 @@ open_file:
 	}
 	/* FIXME: should we abort opening if the link count goes to 0? */
 	if (status == nfs_ok)
-		status = nfsd_open(rqstp, fhp, S_IFREG, may_flags, &nf->nf_file);
+		status = nfsd_open_verified(rqstp, fhp, S_IFREG, may_flags,
+						&nf->nf_file);
 	clear_bit_unlock(NFSD_FILE_PENDING, &nf->nf_flags);
 	smp_mb__after_atomic();
 	wake_up_bit(&nf->nf_flags, NFSD_FILE_PENDING);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a144849cec10..cf4a2018d57a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -640,9 +640,9 @@ nfsd_open_break_lease(struct inode *inode, int access)
  * and additional flags.
  * N.B. After this call fhp needs an fh_put
  */
-__be32
-nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
-			int may_flags, struct file **filp)
+static __be32
+__nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
+	    int may_flags, struct file **filp)
 {
 	struct path	path;
 	struct inode	*inode;
@@ -651,24 +651,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 	__be32		err;
 	int		host_err = 0;
 
-	validate_process_creds();
-
-	/*
-	 * If we get here, then the client has already done an "open",
-	 * and (hopefully) checked permission - so allow OWNER_OVERRIDE
-	 * in case a chmod has now revoked permission.
-	 *
-	 * Arguably we should also allow the owner override for
-	 * directories, but we never have and it doesn't seem to have
-	 * caused anyone a problem.  If we were to change this, note
-	 * also that our filldir callbacks would need a variant of
-	 * lookup_one_len that doesn't check permissions.
-	 */
-	if (type == S_IFREG)
-		may_flags |= NFSD_MAY_OWNER_OVERRIDE;
-	err = fh_verify(rqstp, fhp, type, may_flags);
-	if (err)
-		goto out;
+	BUG_ON(!fhp->fh_dentry);
 
 	path.mnt = fhp->fh_export->ex_path.mnt;
 	path.dentry = fhp->fh_dentry;
@@ -723,6 +706,44 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 out_nfserr:
 	err = nfserrno(host_err);
 out:
+	return err;
+}
+
+__be32
+nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
+			int may_flags, struct file **filp)
+{
+	__be32 err;
+
+	validate_process_creds();
+	/*
+	 * If we get here, then the client has already done an "open",
+	 * and (hopefully) checked permission - so allow OWNER_OVERRIDE
+	 * in case a chmod has now revoked permission.
+	 *
+	 * Arguably we should also allow the owner override for
+	 * directories, but we never have and it doesn't seem to have
+	 * caused anyone a problem.  If we were to change this, note
+	 * also that our filldir callbacks would need a variant of
+	 * lookup_one_len that doesn't check permissions.
+	 */
+	if (type == S_IFREG)
+		may_flags |= NFSD_MAY_OWNER_OVERRIDE;
+	err = fh_verify(rqstp, fhp, type, may_flags);
+	if (!err)
+		err = __nfsd_open(rqstp, fhp, type, may_flags, filp);
+	validate_process_creds();
+	return err;
+}
+
+__be32
+nfsd_open_verified(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
+		   int may_flags, struct file **filp)
+{
+	__be32 err;
+
+	validate_process_creds();
+	err = __nfsd_open(rqstp, fhp, type, may_flags, filp);
 	validate_process_creds();
 	return err;
 }
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a877be59d5dd..b3beb896b08d 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -72,6 +72,8 @@ __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 int		nfsd_open_break_lease(struct inode *, int);
 __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
+__be32		nfsd_open_verified(struct svc_rqst *, struct svc_fh *, umode_t,
+				int, struct file **);
 struct raparms;
 __be32		nfsd_splice_read(struct svc_rqst *,
 				struct file *, loff_t, unsigned long *);
-- 
2.4.3

