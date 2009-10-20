From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH version 2] nfsd: Remove nfsfh.h dependency on sunrpc
Date: Tue, 20 Oct 2009 20:39:46 +0200
Message-ID: <4ADE03F2.5020305@panasas.com>
References: <4ADDCA9A.3060004@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:1132 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751718AbZJTSju (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2009 14:39:50 -0400
In-Reply-To: <4ADDCA9A.3060004@panasas.com>
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
 fs/nfsd/pnfsd_lexp.c       |    3 ++-
 fs/nfsd/spnfs_com.c        |    3 ++-
 include/linux/nfsd/nfsfh.h |    4 ----
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 23789d6..2bcb6b5 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -27,7 +27,8 @@
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/pnfsd.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
-
+#include <linux/nfsd/debug.h>
+ 
 #define NFSDDBG_FACILITY NFSDDBG_PNFS
 
 struct sockaddr pnfsd_lexp_addr;
diff --git a/fs/nfsd/spnfs_com.c b/fs/nfsd/spnfs_com.c
index f8b7b63..7c7d48d 100644
--- a/fs/nfsd/spnfs_com.c
+++ b/fs/nfsd/spnfs_com.c
@@ -58,7 +58,8 @@
 #include <linux/nfs_fs.h>
 
 #include <linux/nfsd4_spnfs.h>
-
+#include <linux/nfsd/debug.h>
+ 
 #define	NFSDDBG_FACILITY		NFSDDBG_PROC
 
 static ssize_t   spnfs_pipe_upcall(struct file *, struct rpc_pipe_msg *,
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


