Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48718 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbbC3OXM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 10:23:12 -0400
Date: Mon, 30 Mar 2015 10:23:10 -0400
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] debugfs: debugfs_create_* shouldn't be checking permissions
Message-ID: <20150330142310.GB6901@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Subject: [PATCH] debugfs: debugfs_create_* shouldn't be checking permissions

Debugfs files and and directories are created by kernel subsystems not
directly by users, so we shouldn't be using lookup_one_len, which checks
permissions.

This was causing krb5 mounts to fail to Fedora servers using gss-proxy
if selinux was enabled, on kernels since 388f0c776781 "sunrpc: add a
debugfs rpc_xprt directory with an info file in it", which creates a new
debugfs directory for each new rpc client.

Reported-by: Anthony Messina <amessina@messinet.com>
Reported-by: Jason Tibbits <tibbs@math.uh.edu>
Cc: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/debugfs/inode.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

I swiped this code fragment from net/sunrpc/rpc_pipe.c, and it's gotten
only minimal testing.  (It does fix krb5 mounts, though.)

diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index 96400ab42d13..75e5daa6a63f 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -251,6 +251,7 @@ static struct dentry *start_creating(const char *name, struct dentry *parent)
 {
 	struct dentry *dentry;
 	int error;
+	struct qstr q = QSTR_INIT(name, strlen(name));
 
 	pr_debug("debugfs: creating file '%s'\n",name);
 
@@ -268,11 +269,19 @@ static struct dentry *start_creating(const char *name, struct dentry *parent)
 		parent = debugfs_mount->mnt_root;
 
 	mutex_lock(&parent->d_inode->i_mutex);
-	dentry = lookup_one_len(name, parent, strlen(name));
-	if (!IS_ERR(dentry) && dentry->d_inode) {
+	dentry = d_hash_and_lookup(parent, &q);
+	if (!dentry) {
+		dentry = d_alloc(parent, &q);
+		if (!dentry) {
+			dentry = ERR_PTR(-ENOMEM);
+			goto out;
+		}
+	}
+	if (dentry->d_inode) {
 		dput(dentry);
 		dentry = ERR_PTR(-EEXIST);
 	}
+out:
 	if (IS_ERR(dentry))
 		mutex_unlock(&parent->d_inode->i_mutex);
 	return dentry;
@@ -340,7 +349,7 @@ struct dentry *debugfs_create_file(const char *name, umode_t mode,
 	inode->i_mode = mode;
 	inode->i_fop = fops ? fops : &debugfs_file_operations;
 	inode->i_private = data;
-	d_instantiate(dentry, inode);
+	d_add(dentry, inode);
 	fsnotify_create(dentry->d_parent->d_inode, dentry);
 	return end_creating(dentry);
 }
@@ -422,7 +431,7 @@ struct dentry *debugfs_create_dir(const char *name, struct dentry *parent)
 
 	/* directory inodes start off with i_nlink == 2 (for "." entry) */
 	inc_nlink(inode);
-	d_instantiate(dentry, inode);
+	d_add(dentry, inode);
 	inc_nlink(dentry->d_parent->d_inode);
 	fsnotify_mkdir(dentry->d_parent->d_inode, dentry);
 	return end_creating(dentry);
-- 
1.9.3

