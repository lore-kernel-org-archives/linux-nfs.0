Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:48781 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbbKPTvL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2015 14:51:11 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <Olga.Kornievskaia@netapp.com>
Subject: [PATCH] NFS: Properly set NFS v4.2 NFSDBG_FACILITY
Date: Mon, 16 Nov 2015 14:51:07 -0500
Message-ID: <1447703467-7459-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS v4.2 operations can work outside of pNFS, so dprintk() output
shouldn't be placed under NFSDBG_PNFS.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 3e92a3c..b2dacc2 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -14,7 +14,7 @@
 #include "pnfs.h"
 #include "internal.h"
 
-#define NFSDBG_FACILITY NFSDBG_PNFS
+#define NFSDBG_FACILITY NFSDBG_PROC
 
 static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
 				fmode_t fmode)
-- 
2.6.2

