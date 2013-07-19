Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:55849 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab3GSVKH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 17:10:07 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 Increase NFS4_DEF_SLOT_TABLE_SIZE
Date: Fri, 19 Jul 2013 17:09:51 -0400
Message-ID: <1374268191-4469-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

max_session_slots is a ushort. Bump NFS4_DEF_SLOT_TABLE_SIZE to the max ushort
value: e.g. ask for 256 slots and let the server negotiate down if needed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4session.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 3a153d8..8b7899f 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -8,7 +8,7 @@
 #define __LINUX_FS_NFS_NFS4SESSION_H
 
 /* maximum number of slots to use */
-#define NFS4_DEF_SLOT_TABLE_SIZE (16U)
+#define NFS4_DEF_SLOT_TABLE_SIZE (256U)
 #define NFS4_MAX_SLOT_TABLE (1024U)
 #define NFS4_NO_SLOT ((u32)-1)
 
-- 
1.8.3.1

