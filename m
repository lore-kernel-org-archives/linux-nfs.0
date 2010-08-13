Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab0HMVcJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:09 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Dean Hildebrand <dhildebz@eecs.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 07/50] pnfs_submit: introduce include/linux/pnfs_xdr.h
Date: Fri, 13 Aug 2010 17:31:19 -0400
Message-Id: <1281735122-1496-8-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-7-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Common xdr data structures needed by pnfs client.

[extracted from: pnfs: Initial check-in of pNFS File Layout Driver.]
Signed-off-by: Dean Hildebrand <dhildebz@eecs.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: Even when CONFIG_PNFS not set some definitions are needed]
    exofs uses the pnfs_osd_xdr.h file, so it must be compilable
    even if CONFIG_PNFS is not set.
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[define all structures unconfitionally]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/pnfs_xdr.h |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/pnfs_xdr.h

diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
new file mode 100644
index 0000000..bcbfbe0
--- /dev/null
+++ b/include/linux/pnfs_xdr.h
@@ -0,0 +1,16 @@
+/*
+ *  include/linux/pnfs_xdr.h
+ *
+ *  Common xdr data structures needed by pnfs client.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ * Dean Hildebrand   <dhildebz@eecs.umich.edu>
+ */
+
+#ifndef LINUX_PNFS_XDR_H
+#define LINUX_PNFS_XDR_H
+
+
+#endif /* LINUX_PNFS_XDR_H */
-- 
1.6.2.5

