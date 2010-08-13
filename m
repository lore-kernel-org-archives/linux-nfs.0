Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736Ab0HMVcI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:08 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Dean Hildebrand <seattleplus@gmail.com>
Subject: [PATCH 06/50] pnfs_submit: introduce include/linux/nfs4_pnfs.h
Date: Fri, 13 Aug 2010 17:31:18 -0400
Message-Id: <1281735122-1496-7-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-6-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Common data structures needed by the pnfs client and pnfs layout driver.

[extraced from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Dean Hildebrand <seattleplus@gmail.com>
[pnfs: nfs4_pnfs.h remove CONFIG_PNFS]
[removed CONFIG_NFS_V4_1 altogether, always define structs]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs4_pnfs.h |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/nfs4_pnfs.h

diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
new file mode 100644
index 0000000..04bdd10
--- /dev/null
+++ b/include/linux/nfs4_pnfs.h
@@ -0,0 +1,15 @@
+/*
+ *  include/linux/nfs4_pnfs.h
+ *
+ *  Common data structures needed by the pnfs client and pnfs layout driver.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Dean Hildebrand   <dhildebz@eecs.umich.edu>
+ */
+
+#ifndef LINUX_NFS4_PNFS_H
+#define LINUX_NFS4_PNFS_H
+
+#endif /* LINUX_NFS4_PNFS_H */
-- 
1.6.2.5

