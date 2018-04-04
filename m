Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:51310 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752383AbeDDWGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:06:49 -0400
Subject: [PATCH 01/12] afs: Invalidate cache on server data change
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:06:47 +0100
Message-ID: <152287960744.14760.15224735251275266488.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Invalidate any data stored in fscache for a vnode that changes on the
server so that we don't end up with the cache in a bad state locally.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/inode.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 6b39d0255b72..42f83fd5a896 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -343,6 +343,10 @@ void afs_zap_data(struct afs_vnode *vnode)
 {
 	_enter("{%x:%u}", vnode->fid.vid, vnode->fid.vnode);
 
+#ifdef CONFIG_AFS_FSCACHE
+	fscache_invalidate(vnode->cache);
+#endif
+
 	/* nuke all the non-dirty pages that aren't locked, mapped or being
 	 * written back in a regular file and completely discard the pages in a
 	 * directory or symlink */

