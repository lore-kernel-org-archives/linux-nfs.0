From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 4/4] nfsd: Minor cleanup of _get_posix_acl
Date: Mon, 20 Oct 2008 11:47:21 +0530
Message-ID: <20081020061721.18370.93671.sendpatchset@localhost.localdomain>
References: <20081020061709.18370.85373.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:43782 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbYJTGRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 02:17:25 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9K6HODR021892
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 02:17:24 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9K6HOpl083934
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 02:17:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9K6HM8o009633
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 02:17:23 -0400
In-Reply-To: <20081020061709.18370.85373.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Rewrite error case to not check twice for !buflen. Compile tested.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 fs/nfsd/vfs.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -ruNp linux-2.6.27.org/fs/nfsd/vfs.c linux-2.6.27.new/fs/nfsd/vfs.c
--- linux-2.6.27.org/fs/nfsd/vfs.c	2008-10-20 10:47:19.000000000 +0530
+++ linux-2.6.27.new/fs/nfsd/vfs.c	2008-10-20 10:48:32.000000000 +0530
@@ -503,10 +503,11 @@ _get_posix_acl(struct dentry *dentry, ch
 	int buflen;
 
 	buflen = nfsd_getxattr(dentry, key, &buf);
-	if (!buflen)
-		buflen = -ENODATA;
-	if (buflen <= 0)
+	if (buflen <= 0) {
+		if (!buflen)
+			buflen = -ENODATA;
 		return ERR_PTR(buflen);
+	}
 
 	pacl = posix_acl_from_xattr(buf, buflen);
 	kfree(buf);
