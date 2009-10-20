From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] nfsd: Remove nfsfh.h dependency on sunrpc
Date: Tue, 20 Oct 2009 16:35:06 +0200
Message-ID: <4ADDCA9A.3060004@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:53026 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752447AbZJTOfE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2009 10:35:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


linux/nfsd/nfsfh.h defines some low level types which
are needed by exportfs and though by filesystems.

In the file, fh_lock() uses the sunrpc dprint facility which
might cause a dependency of exportfs (and filesystems) on
sunrpc which is unwanted.

Remove the debug-print from fh_lock() and avoid this dependency.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/nfsd/nfsfh.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index 94c1aee..b91760c 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -20,7 +20,6 @@
 # include <linux/fs.h>
 #endif
 #include <linux/nfsd/const.h>
-#include <linux/nfsd/debug.h>
 
 /*
  * This is the old "dentry style" Linux NFSv2 file handle.
@@ -330,9 +329,6 @@ fh_lock_nested(struct svc_fh *fhp, unsigned int subclass)
 	struct dentry	*dentry = fhp->fh_dentry;
 	struct inode	*inode;
 
-	dfprintk(FILEOP, "nfsd: fh_lock(%s) locked = %d\n",
-			SVCFH_fmt(fhp), fhp->fh_locked);
-
 	BUG_ON(!dentry);
 
 	if (fhp->fh_locked) {
-- 
1.6.2.1

