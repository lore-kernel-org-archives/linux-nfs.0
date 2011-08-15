Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298Ab1HOWaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:30:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] nfsd: clean up nfsd_mode_check()
Date: Mon, 15 Aug 2011 18:30:32 -0400
Message-Id: <1313447432-1537-5-git-send-email-bfields@redhat.com>
In-Reply-To: <20110815222859.GD32181@fieldses.org>
References: <20110815222859.GD32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add some more comments, simplify logic, do & S_IFMT just once, name
"type" more helpfully.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsfh.c |   52 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index dc0f9ff..b4fd50e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -59,30 +59,36 @@ static int nfsd_acceptable(void *expv, struct dentry *dentry)
  * the write call).
  */
 static inline __be32
-nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int type)
+nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int requested)
 {
-	if (type > 0 && (mode & S_IFMT) != type) {
-		if (rqstp->rq_vers == 4 && (mode & S_IFMT) == S_IFLNK)
-			return nfserr_symlink;
-		else if (type == S_IFDIR)
-			return nfserr_notdir;
-		else if ((mode & S_IFMT) == S_IFDIR)
-			return nfserr_isdir;
-		/*
-		 * err_symlink is our catch-all error in the v4 case; this
-		 * looks odd, but:
-		 *	- the comment next to ERR_SYMLINK in file is
-		 *	  "should be file/directory"
-		 *	- we happen to know this will cause the linux v4
-		 *	  client to do the right thing on attempts to open
-		 *	  something other than a regular file:
-		 */
-		else if (rqstp->rq_vers == 4)
-			return nfserr_symlink;
-		else
-			return nfserr_inval;
-	}
-	return 0;
+	mode &= S_IFMT;
+
+	if (requested == 0) /* the caller doesn't care */
+		return 0;
+	if (mode == requested)
+		return 0;
+	/*
+	 * v4 has an error more specific than err_notdir which we should
+	 * return in preference to err_notdir:
+	 */
+	if (rqstp->rq_vers == 4 && mode == S_IFLNK)
+		return nfserr_symlink;
+	if (requested == S_IFDIR)
+		return nfserr_notdir;
+	if (mode == S_IFDIR)
+		return nfserr_isdir;
+	/*
+	 * err_symlink is our catch-all error in the v4 case; this
+	 * looks odd, but:
+	 *	- the comment next to ERR_SYMLINK in file is
+	 *	  "should be file/directory"
+	 *	- we happen to know this will cause the linux v4
+	 *	  client to do the right thing on attempts to open
+	 *	  something other than a regular file:
+	 */
+	if (rqstp->rq_vers == 4)
+		return nfserr_symlink;
+	return nfserr_inval;
 }
 
 static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
-- 
1.7.4.1

