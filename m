Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:56962 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967761AbaLLOu3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2014 09:50:29 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so3496410qgd.3
        for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 06:50:28 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Thomas Haynes <thomas.haynes@primarydata.com>
Subject: [PATCH] nfs: guard fs/nfs/internal.h against multiple inclusion
Date: Fri, 12 Dec 2014 09:50:18 -0500
Message-Id: <1418395818-22062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Cc: Thomas Haynes <thomas.haynes@primarydata.com>
---
 fs/nfs/internal.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index efaa31c70fbe..ffef459f0b4f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -1,6 +1,8 @@
 /*
  * NFS internal definitions
  */
+#ifndef	__FS_NFS_INTERNAL_H
+#define __FS_NFS_INTERNAL_H
 
 #include "nfs4_fs.h"
 #include <linux/mount.h>
@@ -629,3 +631,5 @@ static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
 	return 0;
 }
 #endif
+
+#endif	/* __FS_NFS_INTERNAL_H */
-- 
2.1.0

