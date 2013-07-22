Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:30524 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126Ab3GVWl3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 18:41:29 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/1] NFSv4.1 Increase NFS4_DEF_SLOT_TABLE_SIZE
Date: Mon, 22 Jul 2013 18:41:23 -0400
Message-ID: <1374532883-50131-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Increase NFS4_DEF_SLOT_TABLE_SIZE which is used as the client ca_maxreequests
value in CREATE_SESSION.  Current non-dynamic session slot server
implementations use the client ca_maxrequests as a maximum slot number: 64
session slots can handle most workloads.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4session.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 3a153d8..86a0669 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -8,7 +8,7 @@
 #define __LINUX_FS_NFS_NFS4SESSION_H
 
 /* maximum number of slots to use */
-#define NFS4_DEF_SLOT_TABLE_SIZE (16U)
+#define NFS4_DEF_SLOT_TABLE_SIZE (64U)
 #define NFS4_MAX_SLOT_TABLE (1024U)
 #define NFS4_NO_SLOT ((u32)-1)
 
-- 
1.8.3.1

