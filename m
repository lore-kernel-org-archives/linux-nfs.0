From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1] nfs: BUG_ON in nfs_follow_mountpoint
Date: Mon, 11 Aug 2008 12:02:34 +0400
Message-ID: <1218441754-20883-1-git-send-email-den@openvz.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: akpm@linux-foundation.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44621 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbYHKICZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2008 04:02:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unfortunately, BUG_ON(IS_ROOT(dentry)) can happen inside
nfs_follow_mountpoint with NFS running Fedora 8 using a
specific setup.
https://bugzilla.redhat.com/show_bug.cgi?id=458622

So, the situation should be handled on NFS client gracefully.

Signed-off-by: Denis V. Lunev <den@openvz.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: J. Bruce Fields <bfields@fieldses.org>
---
 fs/nfs/namespace.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 66df08d..4f11c13 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -105,7 +105,10 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 
 	dprintk("--> nfs_follow_mountpoint()\n");
 
-	BUG_ON(IS_ROOT(dentry));
+	err = -ESTALE;
+	if (IS_ROOT(dentry))
+		goto out_err;
+
 	dprintk("%s: enter\n", __func__);
 	dput(nd->path.dentry);
 	nd->path.dentry = dget(dentry);
-- 
1.5.6.4

