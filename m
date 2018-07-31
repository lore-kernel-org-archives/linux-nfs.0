Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:45777 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732372AbeGaVgc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2018 17:36:32 -0400
Received: by mail-io0-f176.google.com with SMTP id k16-v6so14085738iom.12
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 12:54:39 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/3] NFSv4: Mark the inode change attribute up to date in update_changeattr()
Date: Tue, 31 Jul 2018 15:54:12 -0400
Message-Id: <20180731195412.10912-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180731195412.10912-3-trond.myklebust@hammerspace.com>
References: <20180731195412.10912-1-trond.myklebust@hammerspace.com>
 <20180731195412.10912-2-trond.myklebust@hammerspace.com>
 <20180731195412.10912-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we update the change attribute, we should also clear the flag that
says it is out of date.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2f07a31e2fb6..a8617fa865e5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1107,6 +1107,7 @@ update_changeattr_locked(struct inode *dir, struct nfs4_change_info *cinfo,
 	inode_set_iversion_raw(dir, cinfo->after);
 	nfsi->read_cache_jiffies = timestamp;
 	nfsi->attr_gencount = nfs_inc_attr_generation_counter();
+	nfsi->cache_validity &= ~NFS_INO_INVALID_CHANGE;
 	nfs_fscache_invalidate(dir);
 }
 
-- 
2.17.1

