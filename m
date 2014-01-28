Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:57173 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771AbaA1O4p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jan 2014 09:56:45 -0500
Received: by mail-ie0-f169.google.com with SMTP id to1so503893ieb.14
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jan 2014 06:56:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix races in nfs_revalidate_mapping
Date: Tue, 28 Jan 2014 09:49:10 -0500
Message-Id: <1390920550-5543-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <20140128091849.6f3090cc@tlielax.poochiereds.net>
References: <20140128091849.6f3090cc@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit d529ef83c355f97027ff85298a9709fe06216a66 (NFS: fix the handling
of NFS_INO_INVALID_DATA flag in nfs_revalidate_mapping) introduces
a potential race, since it doesn't test the value of nfsi->cache_validity
and set the bitlock in nfsi->flags atomically.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0a972ee9ccc1..8a5bcb6040ac 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1038,24 +1038,22 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 				  nfs_wait_bit_killable, TASK_KILLABLE);
 		if (ret)
 			goto out;
-		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA))
+		spin_lock(&inode->i_lock);
+		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA)) {
+			spin_unlock(&inode->i_lock);
 			goto out;
+		}
 		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING, bitlock))
 			break;
-	}
-
-	spin_lock(&inode->i_lock);
-	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
-		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
-		spin_unlock(&inode->i_lock);
-		trace_nfs_invalidate_mapping_enter(inode);
-		ret = nfs_invalidate_mapping(inode, mapping);
-		trace_nfs_invalidate_mapping_exit(inode, ret);
-	} else {
-		/* something raced in and cleared the flag */
 		spin_unlock(&inode->i_lock);
 	}
 
+	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
+	spin_unlock(&inode->i_lock);
+	trace_nfs_invalidate_mapping_enter(inode);
+	ret = nfs_invalidate_mapping(inode, mapping);
+	trace_nfs_invalidate_mapping_exit(inode, ret);
+
 	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
 	smp_mb__after_clear_bit();
 	wake_up_bit(bitlock, NFS_INO_INVALIDATING);
-- 
1.8.5.3

