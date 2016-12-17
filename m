Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35454 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754189AbcLQS1R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:17 -0500
Received: by mail-io0-f195.google.com with SMTP id f73so15188370ioe.2
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:17 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] NFSv4: Update the attribute cache info in update_changeattr
Date: Sat, 17 Dec 2016 13:27:04 -0500
Message-Id: <20161217182711.10643-3-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-2-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we successfully updated the change attribute, we should timestamp the
cache. While we do know that the other attributes are not completely up
to date, we have the NFS_INO_INVALID_ATTR flag that let us know that,
so it is valid to say that the cache has not timed out.
We can also clear NFS_INO_REVAL_PAGECACHE, since our change attribute
is now known to be valid.

Conversely, if the change attribute did not match, we should make sure to
also revalidate the access and ACL caches.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 713932440e07..2e0816cb7136 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1091,8 +1091,15 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 	if (dir->i_version == cinfo->after)
 		goto out;
 	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
-	if (!cinfo->atomic || cinfo->before != dir->i_version)
+	if (cinfo->atomic && cinfo->before == dir->i_version) {
+		nfsi->cache_validity &= ~NFS_INO_REVAL_PAGECACHE;
+		nfsi->attrtimeo_timestamp = jiffies;
+	} else {
 		nfs_force_lookup_revalidate(dir);
+		if (cinfo->before != dir->i_version)
+			nfsi->cache_validity |= NFS_INO_INVALID_ACCESS |
+				NFS_INO_INVALID_ACL;
+	}
 	dir->i_version = cinfo->after;
 	nfsi->attr_gencount = nfs_inc_attr_generation_counter();
 	nfs_fscache_invalidate(dir);
-- 
2.9.3

