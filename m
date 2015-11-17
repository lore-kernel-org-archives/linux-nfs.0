Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:34673 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbbKQLxd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:33 -0500
Received: by qgeb1 with SMTP id b1so3410056qge.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:32 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 14/38] nfsd: allow filecache open to skip fh_verify check
Date: Tue, 17 Nov 2015 06:52:36 -0500
Message-Id: <1447761180-4250-15-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
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
index f6adccc6f740..79daf2677176 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -672,7 +672,8 @@ open_file:
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
index bd8b2433a2cb..67cce7554bb3 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -635,9 +635,9 @@ nfsd_open_break_lease(struct inode *inode, int access)
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
@@ -646,24 +646,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
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
@@ -718,6 +701,44 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
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

