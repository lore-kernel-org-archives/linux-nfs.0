From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] nfsd: Fix memory leak in nfsd_getxattr
Date: Wed, 22 Oct 2008 14:48:36 +0530
Message-ID: <20081022091836.22100.57827.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34609 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564AbYJVJSm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 05:18:42 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9M9IdRI028192
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 05:18:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9M9Icn2082514
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 05:18:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9M9Ic0i025742
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 05:18:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Fix a memory leak in nfsd_getxattr. nfsd_getxattr should free up memory
	that it allocated if vfs_getxattr fails.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 fs/nfsd/vfs.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff -ruNp 2.6.27-org/fs/nfsd/vfs.c 2.6.27-new/fs/nfsd/vfs.c
--- 2.6.27-org/fs/nfsd/vfs.c	2008-10-22 14:17:23.000000000 +0530
+++ 2.6.27-new/fs/nfsd/vfs.c	2008-10-22 14:19:15.000000000 +0530
@@ -411,6 +411,7 @@ out_nfserr:
 static ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf)
 {
 	ssize_t buflen;
+	ssize_t ret;
 
 	buflen = vfs_getxattr(dentry, key, NULL, 0);
 	if (buflen <= 0)
@@ -420,7 +421,10 @@ static ssize_t nfsd_getxattr(struct dent
 	if (!*buf)
 		return -ENOMEM;
 
-	return vfs_getxattr(dentry, key, *buf, buflen);
+	ret = vfs_getxattr(dentry, key, *buf, buflen);
+	if (ret < 0)
+		kfree(*buf);
+	return ret;
 }
 #endif
 
