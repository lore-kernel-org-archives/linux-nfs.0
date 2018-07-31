Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:33747 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727999AbeGaTGK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2018 15:06:10 -0400
Received: by mail-it0-f42.google.com with SMTP id d16-v6so13016886itj.0
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 10:24:51 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] NFSv4: Mark the inode change attribute up to date in update_changeattr()
Date: Tue, 31 Jul 2018 13:24:26 -0400
Message-Id: <20180731172426.6491-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180731172426.6491-3-trond.myklebust@hammerspace.com>
References: <20180731172426.6491-1-trond.myklebust@hammerspace.com>
 <20180731172426.6491-2-trond.myklebust@hammerspace.com>
 <20180731172426.6491-3-trond.myklebust@hammerspace.com>
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
index 9d181d76c744..a1faeb2de954 100644
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

