Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46171 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752893Ab0I2LLS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:11:18 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/15] SQUASHME: pnfsblock: remove obsolete include file from blocklayout.h
Date: Wed, 29 Sep 2010 13:11:15 +0200
Message-Id: <1285758675-27082-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index ab61a19..fc0fb23 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -33,8 +33,8 @@
 #define FS_NFS_NFS4BLOCKLAYOUT_H
 
 #include <linux/nfs_fs.h>
-#include <linux/nfs4_pnfs.h>
 #include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
+#include <../pnfs.h>
 
 #define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
 
-- 
1.7.2.3

