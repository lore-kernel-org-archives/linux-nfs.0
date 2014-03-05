Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52090 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbaCEDBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:01:15 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH 1/8] NFS: nfs4_lookup_revalidate: only evaluate parent if it
 will be used.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305030028.27421.54675.stgit@notabene.brown>
In-Reply-To: <20140305025813.27421.23871.stgit@notabene.brown>
References: <20140305025813.27421.23871.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_lookup_revalidate only uses 'parent' to get 'dir', and only
uses 'dir' if 'inode == NULL'.

So we don't need to find out what 'parent' or 'dir' is until we
know that 'inode' is NULL.

By moving 'dget_parent' inside the 'if', we can reduce the number of
call sites for 'dput(parent)'.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be38b573495a..f5509f95f261 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1496,9 +1496,7 @@ EXPORT_SYMBOL_GPL(nfs_atomic_open);
 
 static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 {
-	struct dentry *parent = NULL;
 	struct inode *inode;
-	struct inode *dir;
 	int ret = 0;
 
 	if (flags & LOOKUP_RCU)
@@ -1512,34 +1510,35 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		goto no_open;
 
 	inode = dentry->d_inode;
-	parent = dget_parent(dentry);
-	dir = parent->d_inode;
 
 	/* We can't create new files in nfs_open_revalidate(), so we
 	 * optimize away revalidation of negative dentries.
 	 */
 	if (inode == NULL) {
+		struct dentry *parent;
+		struct inode *dir;
+
+		parent = dget_parent(dentry);
+		dir = parent->d_inode;
 		if (!nfs_neg_need_reval(dir, dentry, flags))
 			ret = 1;
+		dput(parent);
 		goto out;
 	}
 
 	/* NFS only supports OPEN on regular files */
 	if (!S_ISREG(inode->i_mode))
-		goto no_open_dput;
+		goto no_open;
 	/* We cannot do exclusive creation on a positive dentry */
 	if (flags & LOOKUP_EXCL)
-		goto no_open_dput;
+		goto no_open;
 
 	/* Let f_op->open() actually open (and revalidate) the file */
 	ret = 1;
 
 out:
-	dput(parent);
 	return ret;
 
-no_open_dput:
-	dput(parent);
 no_open:
 	return nfs_lookup_revalidate(dentry, flags);
 }


