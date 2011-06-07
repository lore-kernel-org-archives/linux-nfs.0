Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52097 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab1FGReM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:12 -0400
Date: Tue, 7 Jun 2011 13:34:10 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 69/88] SQUASHME: pnfsblock: remove obsolete include file from
 blocklayout.h
Message-ID: <9e7c18549e1c0f68202d6573d8a05d501061c424.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

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
1.7.4.1

