Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38862 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228AbaDPETo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2014 00:19:44 -0400
From: NeilBrown <neilb@suse.de>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 16/19] VFS: use GFP_NOFS rather than GFP_KERNEL in __d_alloc.
Cc: xfs@oss.sgi.com
Message-ID: <20140416040337.10604.61837.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

__d_alloc can be called with i_mutex held, so it is safer to
use GFP_NOFS.

lockdep reports this can deadlock when loop-back NFS is in use,
as nfsd may be required to write out for reclaim, and nfsd certainly
takes i_mutex.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/dcache.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index ca02c13a84aa..3651ff6185b4 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1483,7 +1483,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	struct dentry *dentry;
 	char *dname;
 
-	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
+	dentry = kmem_cache_alloc(dentry_cache, GFP_NOFS);
 	if (!dentry)
 		return NULL;
 
@@ -1495,7 +1495,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	 */
 	dentry->d_iname[DNAME_INLINE_LEN-1] = 0;
 	if (name->len > DNAME_INLINE_LEN-1) {
-		dname = kmalloc(name->len + 1, GFP_KERNEL);
+		dname = kmalloc(name->len + 1, GFP_NOFS);
 		if (!dname) {
 			kmem_cache_free(dentry_cache, dentry); 
 			return NULL;


