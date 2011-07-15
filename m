Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36604 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051Ab1GOXJK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2011 19:09:10 -0400
Date: Fri, 15 Jul 2011 19:09:08 -0400
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: document nfsv4 sillyrename issues
Message-ID: <20110715230908.GD28012@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Somebody working on this code asked what the deal was with NFSv4, since
this comment notes that it's v2/v3's statelessness that requires
sillyrename.  Shouldn't hurt to document the answer.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/unlink.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 8d6864c..981298c 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -501,6 +501,14 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
  * and only performs the unlink once the last reference to it is put.
  *
  * The final cleanup is done during dentry_iput.
+ *
+ * (Note: NFSv4 is stateful, and has opens, so in theory an NFSv4 server
+ * could take responsibility for keeping open files referenced.  The server
+ * would also need to ensure that opened-but-deleted files were kept over
+ * reboots.  However, we may not assume a server does so.  (RFC 5661
+ * does provide an OPEN4_RESULT_PRESERVE_UNLINKED flag that a server can
+ * use to advertise that it does this; some day we may take advantage of
+ * it.))
  */
 int
 nfs_sillyrename(struct inode *dir, struct dentry *dentry)
-- 
1.7.4.1

