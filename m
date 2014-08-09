Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:41875 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaHINnG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2014 09:43:06 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so3686807wiv.0
        for <linux-nfs@vger.kernel.org>; Sat, 09 Aug 2014 06:43:05 -0700 (PDT)
From: Ross Lagerwall <rosslagerwall@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Ross Lagerwall <rosslagerwall@gmail.com>
Subject: [PATCH] nfsd3: Check write permission after checking existence
Date: Sat,  9 Aug 2014 14:44:00 +0100
Message-Id: <1407591840-19080-1-git-send-email-rosslagerwall@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When creating a file that already exists in a read-only directory with
O_EXCL, the NFSv3 server returns EACCES rather than EEXIST (which local
files and the NFSv4 server return).  Fix this by checking the MAY_CREATE
permission only if the file does not exist.  Since this already happens
in do_nfsd_create, the check in nfsd3_proc_create can simply be removed.

Signed-off-by: Ross Lagerwall <rosslagerwall@gmail.com>
---
 fs/nfsd/nfs3proc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 4012899..8ebd4ac 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -227,11 +227,6 @@ nfsd3_proc_create(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
 	newfhp = fh_init(&resp->fh, NFS3_FHSIZE);
 	attr   = &argp->attrs;
 
-	/* Get the directory inode */
-	nfserr = fh_verify(rqstp, dirfhp, S_IFDIR, NFSD_MAY_CREATE);
-	if (nfserr)
-		RETURN_STATUS(nfserr);
-
 	/* Unfudge the mode bits */
 	attr->ia_mode &= ~S_IFMT;
 	if (!(attr->ia_valid & ATTR_MODE)) { 
-- 
2.0.3

