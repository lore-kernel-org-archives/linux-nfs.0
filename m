Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:34679 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbbG3Nwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:52:41 -0400
Received: by ykax123 with SMTP id x123so34373697yka.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:52:40 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] nfsd: allow the file cache expire time to be tunable
Date: Thu, 30 Jul 2015 09:52:21 -0400
Message-Id: <1438264341-18048-11-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is primarily for testing purposes, but this may also be useful
until we have a better idea for a sensible default here.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 55930995a1ec..0f0272cc3683 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -8,6 +8,7 @@
 #include <linux/hash.h>
 #include <linux/file.h>
 #include <linux/sched.h>
+#include <linux/module.h>
 
 #include "vfs.h"
 #include "nfsd.h"
@@ -16,8 +17,10 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_VFS
 
-/* Min time we should keep around a file cache entry */
-#define NFSD_FILE_EXPIRE	(HZ)
+/* Min time we should keep around a file cache entry (in jiffies) */
+static unsigned int			nfsd_file_cache_expiry = HZ;
+module_param(nfsd_file_cache_expiry, uint, 0644);
+MODULE_PARM_DESC(nfsd_file_cache_expiry, "Expire time for open file cache (in jiffies)");
 
 /* We only care about NFSD_MAY_READ/WRITE for this cache */
 #define NFSD_FILE_MAY_MASK	(NFSD_MAY_READ|NFSD_MAY_WRITE)
@@ -40,7 +43,7 @@ nfsd_file_count_inc(void)
 {
 	if (atomic_inc_return(&nfsd_file_count) == 1)
 		queue_delayed_work(nfsd_laundry_wq, &nfsd_file_cache_clean_work,
-					NFSD_FILE_EXPIRE);
+					nfsd_file_cache_expiry);
 }
 
 static void
@@ -169,7 +172,8 @@ nfsd_file_cache_prune(void)
 				continue;
 
 			/* Was this file touched recently? */
-			if (time_before(nf->nf_time + NFSD_FILE_EXPIRE, jiffies))
+			if (time_before(nf->nf_time + nfsd_file_cache_expiry,
+					jiffies))
 				continue;
 
 			/* Ok, it's expired...unhash it */
@@ -193,7 +197,7 @@ nfsd_file_cache_cleaner(struct work_struct *work)
 
 	if (atomic_read(&nfsd_file_count))
 		queue_delayed_work(nfsd_laundry_wq, &nfsd_file_cache_clean_work,
-					NFSD_FILE_EXPIRE);
+					nfsd_file_cache_expiry);
 }
 
 int
-- 
2.4.3

