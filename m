Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753149Ab1BDVef (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:35 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 15/40] REVERT pnfs_submit: increase NFS_MAX_FILE_IO_SIZE
Date: Fri,  4 Feb 2011 16:33:37 -0500
Message-Id: <1296855242-2592-16-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-15-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

We need to demonstrate that this is useful. Revisit as a 'B' item.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs_xdr.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3ea43aa..bd84684 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -10,7 +10,7 @@
  * support a megabyte or more.  The default is left at 4096 bytes, which is
  * reasonable for NFS over UDP.
  */
-#define NFS_MAX_FILE_IO_SIZE	(4U * 1048576U)
+#define NFS_MAX_FILE_IO_SIZE	(1048576U)
 #define NFS_DEF_FILE_IO_SIZE	(4096U)
 #define NFS_MIN_FILE_IO_SIZE	(1024U)
 
-- 
1.6.6

