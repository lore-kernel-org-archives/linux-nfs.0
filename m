Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41537 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab1LDNsk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:48:40 -0500
Received: by eeaq14 with SMTP id q14so1496758eea.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:48:39 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/13] pnfsd-block: mv include/linux/nfsd4_block.h include/linux/nfsd/
Date: Sun,  4 Dec 2011 15:48:28 +0200
Message-Id: <1323006508-13581-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/bl_com.c                       |    2 +-
 fs/nfsd/bl_ops.c                       |    2 +-
 fs/nfsd/export.c                       |    2 +-
 fs/nfsd/nfs4proc.c                     |    2 +-
 fs/nfsd/nfs4xdr.c                      |    2 +-
 fs/nfsd/vfs.c                          |    2 +-
 include/linux/{ => nfsd}/nfsd4_block.h |    0
 7 files changed, 6 insertions(+), 6 deletions(-)
 rename include/linux/{ => nfsd}/nfsd4_block.h (100%)

diff --git a/fs/nfsd/bl_com.c b/fs/nfsd/bl_com.c
index cf37814..388d71a 100644
--- a/fs/nfsd/bl_com.c
+++ b/fs/nfsd/bl_com.c
@@ -19,7 +19,7 @@
 #include <linux/nfs_fs.h>
 
 #include <linux/nfsd/debug.h>
-#include <linux/nfsd4_block.h>
+#include <linux/nfsd/nfsd4_block.h>
 
 #define NFSDDBG_FACILITY NFSDDBG_PNFS
 
diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index 4d2939e..15d2604 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -28,7 +28,7 @@
 #include <linux/dm-ioctl.h>
 #include <asm/uaccess.h>
 #include <linux/falloc.h>
-#include <linux/nfsd4_block.h>
+#include <linux/nfsd/nfsd4_block.h>
 
 #include "pnfsd.h"
 
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 10a05de..9585795 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -19,7 +19,7 @@
 #if defined(CONFIG_SPNFS)
 #include <linux/nfsd4_spnfs.h>
 #if defined(CONFIG_SPNFS_BLOCK)
-#include <linux/nfsd4_block.h>
+#include <linux/nfsd/nfsd4_block.h>
 #endif
 #endif
 #include <net/ipv6.h>
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e4745ca..501781d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -36,7 +36,7 @@
 #include <linux/slab.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
 #include <linux/nfsd4_spnfs.h>
-#include <linux/nfsd4_block.h>
+#include <linux/nfsd/nfsd4_block.h>
 
 #include "idmap.h"
 #include "cache.h"
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index bd8e693..cebd5a2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -49,7 +49,7 @@
 #include <linux/exportfs.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
 #include <linux/nfsd4_spnfs.h>
-#include <linux/nfsd4_block.h>
+#include <linux/nfsd/nfsd4_block.h>
 
 #include "idmap.h"
 #include "acl.h"
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 43efbdc..ce07f67 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -40,7 +40,7 @@
 #include <linux/nfsd4_spnfs.h>
 #endif /* CONFIG_NFSD_V4 */
 #if defined(CONFIG_SPNFS_BLOCK)
-#include <linux/nfsd4_block.h>
+#include <linux/nfsd/nfsd4_block.h>
 #endif
 
 #include "nfsd.h"
diff --git a/include/linux/nfsd4_block.h b/include/linux/nfsd/nfsd4_block.h
similarity index 100%
rename from include/linux/nfsd4_block.h
rename to include/linux/nfsd/nfsd4_block.h
-- 
1.7.6

