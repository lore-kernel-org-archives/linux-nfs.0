Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932709Ab2AMULM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:12 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 01/44] NFS: ifndef guard internal.h
Date: Fri, 13 Jan 2012 15:10:10 -0500
Message-Id: <1326485453-1350-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I ended up with multiple files including this file, so to prevent
compiler errors later on I add ifndef guards now.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5ee9253..1dd22dc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -2,6 +2,9 @@
  * NFS internal definitions
  */
 
+#ifndef __LINUX_NFS_INTERNAL_H
+#define __LINUX_NFS_INTERNAL_H
+
 #include "nfs4_fs.h"
 #include <linux/mount.h>
 #include <linux/security.h>
@@ -461,3 +464,4 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
+#endif /* __LINUX_NFS_INTERNAL_H */
-- 
1.7.8.3

