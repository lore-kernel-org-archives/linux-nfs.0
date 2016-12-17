Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34045 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbcLQS1Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:16 -0500
Received: by mail-io0-f195.google.com with SMTP id y124so15270724iof.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:16 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] NFSv4: Don't invalidate the directory twice
Date: Sat, 17 Dec 2016 13:27:03 -0500
Message-Id: <20161217182711.10643-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-1-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an operation that modified the directory raced with a GETATTR, then we
don't need to invalidate the directory cache more than once.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d33242c8d95d..713932440e07 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1088,12 +1088,15 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 	struct nfs_inode *nfsi = NFS_I(dir);
 
 	spin_lock(&dir->i_lock);
+	if (dir->i_version == cinfo->after)
+		goto out;
 	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 	if (!cinfo->atomic || cinfo->before != dir->i_version)
 		nfs_force_lookup_revalidate(dir);
 	dir->i_version = cinfo->after;
 	nfsi->attr_gencount = nfs_inc_attr_generation_counter();
 	nfs_fscache_invalidate(dir);
+out:
 	spin_unlock(&dir->i_lock);
 }
 
-- 
2.9.3

