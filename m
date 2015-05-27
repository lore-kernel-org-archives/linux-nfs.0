Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36054 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbbE0IFR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 May 2015 04:05:17 -0400
Received: by pdfh10 with SMTP id h10so3959848pdf.3
        for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 01:05:16 -0700 (PDT)
Message-ID: <55657AB6.6060105@gmail.com>
Date: Wed, 27 May 2015 16:05:10 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] NFSD: Process time setting separately only for nfsv2
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv2 does not different between "set-[ac]time-to-now" which only
requires access, and "set-[ac]time-to-X" which requires ownership.

But, NFSv3/v4 are support the difference.
Just let those codes valid for NFSv2.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/vfs.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 84d770b..bf4a15b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -300,7 +300,7 @@ commit_metadata(struct svc_fh *fhp)
  * NFS semantics and what Linux expects.
  */
 static void
-nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
+nfsd_sanitize_attrs(struct svc_rqst *rqstp, struct inode *inode, struct iattr *iap)
 {
 	/*
 	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
@@ -315,7 +315,8 @@ nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
 	 */
 #define BOTH_TIME_SET (ATTR_ATIME_SET | ATTR_MTIME_SET)
 #define	MAX_TOUCH_TIME_ERROR (30*60)
-	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
+	if (rqstp->rq_vers == 2 &&
+	    (iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
 	    iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec) {
 		/*
 		 * Looks probable.
@@ -435,7 +436,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (!iap->ia_valid)
 		goto out;
 
-	nfsd_sanitize_attrs(inode, iap);
+	nfsd_sanitize_attrs(rqstp, inode, iap);
 
 	/*
 	 * The size case is special, it changes the file in addition to the
-- 
2.4.1

