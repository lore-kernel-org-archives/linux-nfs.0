Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:49632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752262AbeDDWHE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:07:04 -0400
Subject: [PATCH 03/12] afs: Be more aggressive in retiring cached vnodes
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:02 +0100
Message-ID: <152287962276.14760.9298205710182682407.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When relinquishing cookies, either due to iget failure or to inode
eviction, retire a cookie if we think the corresponding vnode got deleted
on the server rather than just letting it lie in the cache.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/inode.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 42f83fd5a896..c942c79fc5f0 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -327,7 +327,7 @@ struct inode *afs_iget(struct super_block *sb, struct key *key,
 	/* failure */
 bad_inode:
 #ifdef CONFIG_AFS_FSCACHE
-	fscache_relinquish_cookie(vnode->cache, 0);
+	fscache_relinquish_cookie(vnode->cache, ret == -ENOENT);
 	vnode->cache = NULL;
 #endif
 	iget_failed(inode);
@@ -511,7 +511,8 @@ void afs_evict_inode(struct inode *inode)
 	}
 
 #ifdef CONFIG_AFS_FSCACHE
-	fscache_relinquish_cookie(vnode->cache, 0);
+	fscache_relinquish_cookie(vnode->cache,
+				  test_bit(AFS_VNODE_DELETED, &vnode->flags));
 	vnode->cache = NULL;
 #endif
 

