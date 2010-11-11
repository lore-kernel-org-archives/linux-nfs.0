Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:46175 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756316Ab0KKMyb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 07:54:31 -0500
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] nfs: Ignore kmemleak false positive in nfs_readdir_make_qstr
Date: Thu, 11 Nov 2010 12:53:47 +0000
Message-Id: <1289480027-7361-1-git-send-email-catalin.marinas@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Strings allocated via kmemdup() in nfs_readdir_make_qstr() are
referenced from the nfs_cache_array which is stored in a page cache
page. Kmemleak does not scan such pages and it reports several false
positives. This patch annotates the string->name pointer so that
kmemleak does not consider it a real leak.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 07ac384..a9f9e14 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -34,6 +34,7 @@
 #include <linux/mount.h>
 #include <linux/sched.h>
 #include <linux/vmalloc.h>
+#include <linux/kmemleak.h>
 
 #include "delegation.h"
 #include "iostat.h"
@@ -231,6 +232,11 @@ int nfs_readdir_make_qstr(struct qstr *string, const char *name, unsigned int le
 	string->name = kmemdup(name, len, GFP_KERNEL);
 	if (string->name == NULL)
 		return -ENOMEM;
+	/*
+	 * Avoid a kmemleak false positive. The pointer to the name is stored
+	 * in a page cache page which kmemleak does not scan.
+	 */
+	kmemleak_not_leak(string->name);
 	string->hash = full_name_hash(name, len);
 	return 0;
 }
-- 
1.7.3.GIT

