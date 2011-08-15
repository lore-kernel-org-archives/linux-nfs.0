Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43960 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab1HOWaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:30:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd: open-code special directory-hardlink check
Date: Mon, 15 Aug 2011 18:30:31 -0400
Message-Id: <1313447432-1537-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20110815222859.GD32181@fieldses.org>
References: <20110815222859.GD32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We allow the fh_verify caller to specify that any object *except* those
of a given type is allowed, by passing a negative type.  But only one
caller actually uses it.  Open-code that check in the one caller.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsfh.c |    9 ---------
 fs/nfsd/vfs.c   |    6 ++++--
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index cc8eb8d..dc0f9ff 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -61,7 +61,6 @@ static int nfsd_acceptable(void *expv, struct dentry *dentry)
 static inline __be32
 nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int type)
 {
-	/* Type can be negative when creating hardlinks - not to a dir */
 	if (type > 0 && (mode & S_IFMT) != type) {
 		if (rqstp->rq_vers == 4 && (mode & S_IFMT) == S_IFLNK)
 			return nfserr_symlink;
@@ -83,14 +82,6 @@ nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int type)
 		else
 			return nfserr_inval;
 	}
-	if (type < 0 && (mode & S_IFMT) == -type) {
-		if (rqstp->rq_vers == 4 && (mode & S_IFMT) == S_IFLNK)
-			return nfserr_symlink;
-		else if (type == -S_IFDIR)
-			return nfserr_isdir;
-		else
-			return nfserr_notdir;
-	}
 	return 0;
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 556ca2b..4c22870 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1632,10 +1632,12 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE);
 	if (err)
 		goto out;
-	err = fh_verify(rqstp, tfhp, -S_IFDIR, NFSD_MAY_NOP);
+	err = fh_verify(rqstp, tfhp, 0, NFSD_MAY_NOP);
 	if (err)
 		goto out;
-
+	err = nfserr_isdir;
+	if (S_ISDIR(tfhp->fh_dentry->d_inode->i_mode))
+		goto out;
 	err = nfserr_perm;
 	if (!len)
 		goto out;
-- 
1.7.4.1

