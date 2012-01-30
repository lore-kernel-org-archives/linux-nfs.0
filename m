Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55578 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754433Ab2A3Wms (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 17:42:48 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd: cleanup setting of default max_block_size
Date: Mon, 30 Jan 2012 17:42:44 -0500
Message-Id: <1327963365-2921-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Move calculation of the default into a helper function.

Get rid of an unused variable "err" while we're there.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c |   44 ++++++++++++++++++++++++--------------------
 1 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index eda7d7e..2ad5ffe 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -307,33 +307,37 @@ static void set_max_drc(void)
 	dprintk("%s nfsd_drc_max_mem %u \n", __func__, nfsd_drc_max_mem);
 }
 
-int nfsd_create_serv(void)
+static int nfsd_get_default_max_blksize(void)
 {
-	int err = 0;
+	struct sysinfo i;
+	unsigned long target;
+	unsigned long bytes;
+
+	si_meminfo(&i);
+	target = i.totalram << PAGE_SHIFT;
+	/*
+	 * Aim for 1/4096 of memory per thread This gives 1MB on 4Gig
+	 * machines, but only uses 32K on 128M machines.  Bottom out at
+	 * 8K on 32M and smaller.  Of course, this is only a default.
+	 */
+	target <<= 12;
+
+	bytes = NFSSVC_MAXBLKSIZE;
+	while (bytes > target && bytes >= 8*1024*2)
+		bytes /= 2;
+	return bytes;
+}
 
+int nfsd_create_serv(void)
+{
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nfsd_serv) {
 		svc_get(nfsd_serv);
 		return 0;
 	}
-	if (nfsd_max_blksize == 0) {
-		/* choose a suitable default */
-		struct sysinfo i;
-		si_meminfo(&i);
-		/* Aim for 1/4096 of memory per thread
-		 * This gives 1MB on 4Gig machines
-		 * But only uses 32K on 128M machines.
-		 * Bottom out at 8K on 32M and smaller.
-		 * Of course, this is only a default.
-		 */
-		nfsd_max_blksize = NFSSVC_MAXBLKSIZE;
-		i.totalram <<= PAGE_SHIFT - 12;
-		while (nfsd_max_blksize > i.totalram &&
-		       nfsd_max_blksize >= 8*1024*2)
-			nfsd_max_blksize /= 2;
-	}
+	if (nfsd_max_blksize == 0)
+		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions();
-
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
@@ -341,7 +345,7 @@ int nfsd_create_serv(void)
 
 	set_max_drc();
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
-	return err;
+	return 0;
 }
 
 int nfsd_nrpools(void)
-- 
1.7.5.4

