Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53430 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752436AbaGNBbg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jul 2014 21:31:36 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 14 Jul 2014 11:28:20 +1000
Subject: [PATCH 6/7] NFS: teach nfs_lookup_verify_inode to handle LOOKUP_RCU
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140714012820.12562.26339.stgit@notabene.brown>
In-Reply-To: <20140714011630.12562.1940.stgit@notabene.brown>
References: <20140714011630.12562.1940.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It fails with -ECHILD rather than make an RPC call.

This allows nfs_lookup_revalidate to call it in RCU-walk mode.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index de9bc809c7ea..af8c7464d29b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1050,6 +1050,8 @@ int nfs_lookup_verify_inode(struct inode *inode, unsigned int flags)
 out:
 	return (inode->i_nlink == 0) ? -ENOENT : 0;
 out_force:
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
 	ret = __nfs_revalidate_inode(server, inode);
 	if (ret != 0)
 		return ret;
@@ -1135,11 +1137,11 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (!nfs_is_exclusive_create(dir, flags) &&
 	    nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU)) {
 
-		if (flags & LOOKUP_RCU)
-			return -ECHILD;
-
-		if (nfs_lookup_verify_inode(inode, flags))
+		if (nfs_lookup_verify_inode(inode, flags)) {
+			if (flags & LOOKUP_RCU)
+				return -ECHILD;
 			goto out_zap_parent;
+		}
 		goto out_valid;
 	}
 


