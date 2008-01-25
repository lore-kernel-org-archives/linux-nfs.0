From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 040/100] nfsd: allow root to set uid and gid on create
Date: Fri, 25 Jan 2008 18:16:20 -0500
Message-ID: <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761861AbYAYXRi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:38 -0500
In-Reply-To: <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server silently ignores attempts to set the uid and gid on create.
Based on the comment, this appears to have been done to prevent some
overly-clever IRIX client from causing itself problems.

Perhaps we should remove that hack completely.  For now, at least, it
makes sense to allow root (when no_root_squash is set) to set uid and
gid.

While we're there, since nfsd_create and nfsd_create_v3 share the same
logic, pull that out into a separate function.  And spell out the
individual modifications of ia_valid instead of doing them both at once
inside a conditional.

Thanks to Roger Willcocks <roger-nMHR1cC4sak0YOejwGmHqw@public.gmane.org> for the bug report
and original patch on which this is based.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |   47 ++++++++++++++++++++++++++++-------------------
 1 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 755ba43..cc75e4f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1151,6 +1151,26 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif /* CONFIG_NFSD_V3 */
 
+__be32
+nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
+			struct iattr *iap)
+{
+	/*
+	 * Mode has already been set earlier in create:
+	 */
+	iap->ia_valid &= ~ATTR_MODE;
+	/*
+	 * Setting uid/gid works only for root.  Irix appears to
+	 * send along the gid on create when it tries to implement
+	 * setgid directories via NFS:
+	 */
+	if (current->fsuid != 0)
+		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
+	if (iap->ia_valid)
+		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
+	return 0;
+}
+
 /*
  * Create a file (regular, directory, device, fifo); UNIX sockets 
  * not yet implemented.
@@ -1167,6 +1187,7 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct dentry	*dentry, *dchild = NULL;
 	struct inode	*dirp;
 	__be32		err;
+	__be32		err2;
 	int		host_err;
 
 	err = nfserr_perm;
@@ -1257,16 +1278,9 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 
-	/* Set file attributes. Mode has already been set and
-	 * setting uid/gid works only for root. Irix appears to
-	 * send along the gid when it tries to implement setgid
-	 * directories via NFS.
-	 */
-	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0) {
-		__be32 err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
-		if (err2)
-			err = err2;
-	}
+	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
+	if (err2)
+		err = err2;
 	/*
 	 * Update the file handle to get the new inode info.
 	 */
@@ -1295,6 +1309,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct dentry	*dentry, *dchild = NULL;
 	struct inode	*dirp;
 	__be32		err;
+	__be32		err2;
 	int		host_err;
 	__u32		v_mtime=0, v_atime=0;
 
@@ -1399,16 +1414,10 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		iap->ia_atime.tv_nsec = 0;
 	}
 
-	/* Set file attributes.
-	 * Irix appears to send along the gid when it tries to
-	 * implement setgid directories via NFS. Clear out all that cruft.
-	 */
  set_attr:
-	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0) {
- 		__be32 err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
-		if (err2)
-			err = err2;
-	}
+	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
+	if (err2)
+		err = err2;
 
 	/*
 	 * Update the filehandle to get the new inode info.
-- 
1.5.4.rc2.60.gb2e62

