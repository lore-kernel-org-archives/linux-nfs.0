From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 01/12] nfsd: Remove nfsfh.h dependency on sunrpc
Date: Thu,  3 Dec 2009 20:28:04 +0200
Message-ID: <1259864884-4661-1-git-send-email-bharrosh@panasas.com>
References: <4B1802D0.8060206@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30036 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754198AbZLCS2A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 13:28:00 -0500
In-Reply-To: <4B1802D0.8060206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux/nfsd/nfsfh.h defines some low level types which
are needed by exportfs and though by filesystems.

In the file, fh_lock() uses the sunrpc dprint facility which
might cause a dependency of exportfs (and filesystems) on
sunrpc which is unwanted / unexpected.

Remove the debug-print from fh_lock() and avoid this dependency.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/nfsd/nfsfh.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index 8f641c9..2973e11 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -20,7 +20,6 @@
 # include <linux/fs.h>
 #endif
 #include <linux/nfsd/const.h>
-#include <linux/nfsd/debug.h>
 
 /*
  * This is the old "dentry style" Linux NFSv2 file handle.
@@ -329,9 +328,6 @@ fh_lock_nested(struct svc_fh *fhp, unsigned int subclass)
 	struct dentry	*dentry = fhp->fh_dentry;
 	struct inode	*inode;
 
-	dfprintk(FILEOP, "nfsd: fh_lock(%s) locked = %d\n",
-			SVCFH_fmt(fhp), fhp->fh_locked);
-
 	BUG_ON(!dentry);
 
 	if (fhp->fh_locked) {
-- 
1.6.5.2

