Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:55678 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114AbaA1Plg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jan 2014 10:41:36 -0500
Received: by mail-ie0-f180.google.com with SMTP id at1so560214iec.25
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jan 2014 07:41:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFS: Fix races in nfs_revalidate_mapping
Date: Tue, 28 Jan 2014 10:41:39 -0500
Message-Id: <1390923699-11011-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <20140128101037.35e04fb7@tlielax.poochiereds.net>
References: <20140128101037.35e04fb7@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit d529ef83c355f97027ff85298a9709fe06216a66 (NFS: fix the handling
of NFS_INO_INVALID_DATA flag in nfs_revalidate_mapping) introduces
a potential race, since it doesn't test the value of nfsi->cache_validity
and set the bitlock in nfsi->flags atomically.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/inode.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0a972ee9ccc1..1ff95ba4fea3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1038,23 +1038,24 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 				  nfs_wait_bit_killable, TASK_KILLABLE);
 		if (ret)
 			goto out;
-		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA))
+		spin_lock(&inode->i_lock);
+		if (test_bit(NFS_INO_INVALIDATING, bitlock)) {
+			spin_unlock(&inode->i_lock);
+			continue;
+		}
+		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA)) {
+			spin_unlock(&inode->i_lock);
 			goto out;
-		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING, bitlock))
-			break;
+		}
+		set_bit(NFS_INO_INVALIDATING, bitlock);
+		break;
 	}
 
-	spin_lock(&inode->i_lock);
-	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
-		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
-		spin_unlock(&inode->i_lock);
-		trace_nfs_invalidate_mapping_enter(inode);
-		ret = nfs_invalidate_mapping(inode, mapping);
-		trace_nfs_invalidate_mapping_exit(inode, ret);
-	} else {
-		/* something raced in and cleared the flag */
-		spin_unlock(&inode->i_lock);
-	}
+	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
+	spin_unlock(&inode->i_lock);
+	trace_nfs_invalidate_mapping_enter(inode);
+	ret = nfs_invalidate_mapping(inode, mapping);
+	trace_nfs_invalidate_mapping_exit(inode, ret);
 
 	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
 	smp_mb__after_clear_bit();
-- 
1.8.5.3

