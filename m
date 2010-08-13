Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0HMVcK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:10 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Dean Hildebrand <dhildebz@eecs.umich.edu>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 08/50] pnfs_submit: introduce fs/nfs/pnfs.h
Date: Fri, 13 Aug 2010 17:31:20 -0400
Message-Id: <1281735122-1496-9-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-8-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

pNFS client data structures.

[extraceted from: pnfs: Initial check-in of pNFS File Layout Driver.]
Signed-off-by: Dean Hildebrand <dhildebz@eecs.umich.edu>
[pnfs: pnfs.h: remove CONFIG_PNFS]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)
 create mode 100644 fs/nfs/pnfs.h

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
new file mode 100644
index 0000000..7b5ebd9
--- /dev/null
+++ b/fs/nfs/pnfs.h
@@ -0,0 +1,18 @@
+/*
+ *  fs/nfs/pnfs.h
+ *
+ *  pNFS client data structures.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Dean Hildebrand   <dhildebz@eecs.umich.edu>
+ */
+
+#ifndef FS_NFS_PNFS_H
+#define FS_NFS_PNFS_H
+
+#ifdef CONFIG_NFS_V4_1
+#endif /* CONFIG_NFS_V4_1 */
+
+#endif /* FS_NFS_PNFS_H */
-- 
1.6.2.5

