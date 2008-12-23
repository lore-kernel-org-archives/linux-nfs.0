From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 40/69] NFSv4: Clean up is_atomic_open()
Date: Tue, 23 Dec 2008 18:02:17 -0500
Message-ID: <20081223230217.13743.82583.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588AbYLWXXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:48 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7k021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3e64b98..121b533 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -973,7 +973,7 @@ struct dentry_operations nfs4_dentry_operations = {
  * Use intent information to determine whether we need to substitute
  * the NFSv4-style stateful OPEN for the LOOKUP call
  */
-static int is_atomic_open(struct inode *dir, struct nameidata *nd)
+static int is_atomic_open(struct nameidata *nd)
 {
 	if (nd == NULL || nfs_lookup_check_intent(nd, LOOKUP_OPEN) == 0)
 		return 0;
@@ -996,7 +996,7 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
 
 	/* Check that we are indeed trying to open this file */
-	if (!is_atomic_open(dir, nd))
+	if (!is_atomic_open(nd))
 		goto no_open;
 
 	if (dentry->d_name.len > NFS_SERVER(dir)->namelen) {
@@ -1047,10 +1047,10 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct inode *dir;
 	int openflags, ret = 0;
 
+	if (!is_atomic_open(nd))
+		goto no_open;
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
-	if (!is_atomic_open(dir, nd))
-		goto no_open;
 	/* We can't create new files in nfs_open_revalidate(), so we
 	 * optimize away revalidation of negative dentries.
 	 */
@@ -1062,11 +1062,11 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 
 	/* NFS only supports OPEN on regular files */
 	if (!S_ISREG(inode->i_mode))
-		goto no_open;
+		goto no_open_dput;
 	openflags = nd->intent.open.flags;
 	/* We cannot do exclusive creation on a positive dentry */
 	if ((openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL))
-		goto no_open;
+		goto no_open_dput;
 	/* We can't create new files, or truncate existing ones here */
 	openflags &= ~(O_CREAT|O_TRUNC);
 
@@ -1081,8 +1081,9 @@ out:
 	if (!ret)
 		d_drop(dentry);
 	return ret;
-no_open:
+no_open_dput:
 	dput(parent);
+no_open:
 	if (inode != NULL && nfs_have_delegation(inode, FMODE_READ))
 		return 1;
 	return nfs_lookup_revalidate(dentry, nd);

