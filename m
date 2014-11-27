Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:29550 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbaK0P50 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Nov 2014 10:57:26 -0500
Date: Thu, 27 Nov 2014 18:58:54 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] nfsd: minor off by one checks in __write_versions()
Message-ID: <20141127155854.GB21914@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My static checker complains that if "len == remaining" then it means we
have truncated the last character off the version string.

The intent of the code is that we print as many versions as we can
without truncating a version.  Then we put a newline at the end.  If the
newline can't fit we return -EINVAL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9506ea5..19ace74 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -608,7 +608,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 				       num);
 			sep = " ";
 
-			if (len > remaining)
+			if (len >= remaining)
 				break;
 			remaining -= len;
 			buf += len;
@@ -623,7 +623,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 						'+' : '-',
 					minor);
 
-			if (len > remaining)
+			if (len >= remaining)
 				break;
 			remaining -= len;
 			buf += len;
@@ -631,7 +631,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 		}
 
 	len = snprintf(buf, remaining, "\n");
-	if (len > remaining)
+	if (len >= remaining)
 		return -EINVAL;
 	return tlen + len;
 }
