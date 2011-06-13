Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22898 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab1FMU4Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 16:56:16 -0400
Message-ID: <4DF6796F.9020707@panasas.com>
Date: Mon, 13 Jun 2011 16:56:15 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] exofs: pnfs-tree: Remove pnfs-osd private definitions
References: <4DF678C5.1080001@panasas.com>
In-Reply-To: <4DF678C5.1080001@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Now that pnfs-osd has hit mainline we can remove exofs's
private header. (And the FIXME comment)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/exofs.h |    6 +-----
 fs/exofs/pnfs.h  |   45 ---------------------------------------------
 2 files changed, 1 insertions(+), 50 deletions(-)
 delete mode 100644 fs/exofs/pnfs.h

diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index c965806..e103dbd 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -36,13 +36,9 @@
 #include <linux/fs.h>
 #include <linux/time.h>
 #include <linux/backing-dev.h>
+#include <linux/pnfs_osd_xdr.h>
 #include "common.h"
 
-/* FIXME: Remove once pnfs hits mainline
- * #include <linux/exportfs/pnfs_osd_xdr.h>
- */
-#include "pnfs.h"
-
 #define EXOFS_ERR(fmt, a...) printk(KERN_ERR "exofs: " fmt, ##a)
 
 #ifdef CONFIG_EXOFS_DEBUG
diff --git a/fs/exofs/pnfs.h b/fs/exofs/pnfs.h
deleted file mode 100644
index c52e988..0000000
--- a/fs/exofs/pnfs.h
+++ /dev/null
@@ -1,45 +0,0 @@
-/*
- * Copyright (C) 2008, 2009
- * Boaz Harrosh <bharrosh@panasas.com>
- *
- * This file is part of exofs.
- *
- * exofs is free software; you can redistribute it and/or modify it under the
- * terms of the GNU General Public License  version 2 as published by the Free
- * Software Foundation.
- *
- */
-
-/* FIXME: Remove this file once pnfs hits mainline */
-
-#ifndef __EXOFS_PNFS_H__
-#define __EXOFS_PNFS_H__
-
-#if ! defined(__PNFS_OSD_XDR_H__)
-
-enum pnfs_iomode {
-	IOMODE_READ = 1,
-	IOMODE_RW = 2,
-	IOMODE_ANY = 3,
-};
-
-/* Layout Structure */
-enum pnfs_osd_raid_algorithm4 {
-	PNFS_OSD_RAID_0		= 1,
-	PNFS_OSD_RAID_4		= 2,
-	PNFS_OSD_RAID_5		= 3,
-	PNFS_OSD_RAID_PQ	= 4     /* Reed-Solomon P+Q */
-};
-
-struct pnfs_osd_data_map {
-	u32	odm_num_comps;
-	u64	odm_stripe_unit;
-	u32	odm_group_width;
-	u32	odm_group_depth;
-	u32	odm_mirror_cnt;
-	u32	odm_raid_algorithm;
-};
-
-#endif /* ! defined(__PNFS_OSD_XDR_H__) */
-
-#endif /* __EXOFS_PNFS_H__ */
-- 
1.7.3.4


