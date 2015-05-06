Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34402 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbbEFGvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 02:51:07 -0400
Received: by wicmx19 with SMTP id mx19so117587959wic.1
        for <linux-nfs@vger.kernel.org>; Tue, 05 May 2015 23:51:06 -0700 (PDT)
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>, Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
Date: Wed,  6 May 2015 08:50:24 +0200
Message-Id: <1430895024-1403-1-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv2 protocol does not have a way to set the atime or mtime of a
file to the server's current time, only to specific timestamps.  To make
up for that, when a client sets both atime and mtime to the same
timestamp and that timestamp is within the last half hour, the server
sets them to its own current time instead.

The NFSv3 and later protocols do support setting atime or mtime to the
server's current time and clients do use that, so skip the NFSv2
workaround there.

With this change, clients which have write access but are not the owner
can still do the equivalent of utimes("file", NULL), for example with
"touch", but setting atime or mtime to any other value will now
consistently fail.  This is also the local, non-NFS behavior.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/vfs.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 84d770b..41d3359 100644
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
@@ -316,7 +316,8 @@ nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
 #define BOTH_TIME_SET (ATTR_ATIME_SET | ATTR_MTIME_SET)
 #define	MAX_TOUCH_TIME_ERROR (30*60)
 	if ((iap->ia_valid & BOTH_TIME_SET) == BOTH_TIME_SET &&
-	    iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec) {
+	    iap->ia_mtime.tv_sec == iap->ia_atime.tv_sec &&
+	    rqstp->rq_vers == 2) {
 		/*
 		 * Looks probable.
 		 *
@@ -435,7 +436,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (!iap->ia_valid)
 		goto out;
 
-	nfsd_sanitize_attrs(inode, iap);
+	nfsd_sanitize_attrs(rqstp, inode, iap);
 
 	/*
 	 * The size case is special, it changes the file in addition to the
-- 
2.1.0

