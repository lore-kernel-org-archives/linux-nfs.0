Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f48.google.com ([209.85.214.48]:55927 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab3HFOaZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 10:30:25 -0400
Received: by mail-bk0-f48.google.com with SMTP id jf20so183682bkc.7
        for <linux-nfs@vger.kernel.org>; Tue, 06 Aug 2013 07:30:24 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: rwheeler@redhat.com, avati@redhat.com, viro@ZenIV.linux.org.uk
Cc: bfoster@redhat.com, dhowells@redhat.com, eparis@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        swhiteho@redhat.com, mszeredi@suse.cz
Subject: [PATCH 3/4] fuse: use d_materialise_unique()
Date: Tue,  6 Aug 2013 16:30:02 +0200
Message-Id: <1375799403-28544-4-git-send-email-miklos@szeredi.hu>
In-Reply-To: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
References: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Miklos Szeredi <mszeredi@suse.cz>

Use d_materialise_unique() instead of d_splice_alias().  This allows dentry
subtrees to be moved to a new place if there moved, even if something is
referencing a dentry in the subtree (open fd, cwd, etc..).

This will also allow us to drop a subtree if it is found to be replaced by
something else.  In this case the disconnected subtree can later be
reconnected to its new location.

d_materialise_unique() ensures that a directory entry only ever has one
alias.  We keep fc->inst_mutex around the calls for d_materialise_unique()
on directories to prevent a race with mkdir "stealing" the inode.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/dir.c | 69 ++++++++++++++++++++++-------------------------------------
 1 file changed, 26 insertions(+), 43 deletions(-)

diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 72a5d5b..131d14b 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -267,26 +267,6 @@ int fuse_valid_type(int m)
 		S_ISBLK(m) || S_ISFIFO(m) || S_ISSOCK(m);
 }
 
-/*
- * Add a directory inode to a dentry, ensuring that no other dentry
- * refers to this inode.  Called with fc->inst_mutex.
- */
-static struct dentry *fuse_d_add_directory(struct dentry *entry,
-					   struct inode *inode)
-{
-	struct dentry *alias = d_find_alias(inode);
-	if (alias && !(alias->d_flags & DCACHE_DISCONNECTED)) {
-		/* This tries to shrink the subtree below alias */
-		fuse_invalidate_entry(alias);
-		dput(alias);
-		if (!hlist_empty(&inode->i_dentry))
-			return ERR_PTR(-EBUSY);
-	} else {
-		dput(alias);
-	}
-	return d_splice_alias(inode, entry);
-}
-
 int fuse_lookup_name(struct super_block *sb, u64 nodeid, struct qstr *name,
 		     struct fuse_entry_out *outarg, struct inode **inode)
 {
@@ -345,6 +325,24 @@ int fuse_lookup_name(struct super_block *sb, u64 nodeid, struct qstr *name,
 	return err;
 }
 
+static struct dentry *fuse_materialise_dentry(struct dentry *dentry,
+					      struct inode *inode)
+{
+	struct dentry *newent;
+
+	if (inode && S_ISDIR(inode->i_mode)) {
+		struct fuse_conn *fc = get_fuse_conn(inode);
+
+		mutex_lock(&fc->inst_mutex);
+		newent = d_materialise_unique(dentry, inode);
+		mutex_unlock(&fc->inst_mutex);
+	} else {
+		newent = d_materialise_unique(dentry, inode);
+	}
+
+	return newent;
+}
+
 static struct dentry *fuse_lookup(struct inode *dir, struct dentry *entry,
 				  unsigned int flags)
 {
@@ -352,7 +350,6 @@ static struct dentry *fuse_lookup(struct inode *dir, struct dentry *entry,
 	struct fuse_entry_out outarg;
 	struct inode *inode;
 	struct dentry *newent;
-	struct fuse_conn *fc = get_fuse_conn(dir);
 	bool outarg_valid = true;
 
 	err = fuse_lookup_name(dir->i_sb, get_node_id(dir), &entry->d_name,
@@ -368,16 +365,10 @@ static struct dentry *fuse_lookup(struct inode *dir, struct dentry *entry,
 	if (inode && get_node_id(inode) == FUSE_ROOT_ID)
 		goto out_iput;
 
-	if (inode && S_ISDIR(inode->i_mode)) {
-		mutex_lock(&fc->inst_mutex);
-		newent = fuse_d_add_directory(entry, inode);
-		mutex_unlock(&fc->inst_mutex);
-		err = PTR_ERR(newent);
-		if (IS_ERR(newent))
-			goto out_iput;
-	} else {
-		newent = d_splice_alias(inode, entry);
-	}
+	newent = fuse_materialise_dentry(entry, inode);
+	err = PTR_ERR(newent);
+	if (IS_ERR(newent))
+		goto out_err;
 
 	entry = newent ? newent : entry;
 	if (outarg_valid)
@@ -1275,18 +1266,10 @@ static int fuse_direntplus_link(struct file *file,
 	if (!inode)
 		goto out;
 
-	if (S_ISDIR(inode->i_mode)) {
-		mutex_lock(&fc->inst_mutex);
-		alias = fuse_d_add_directory(dentry, inode);
-		mutex_unlock(&fc->inst_mutex);
-		err = PTR_ERR(alias);
-		if (IS_ERR(alias)) {
-			iput(inode);
-			goto out;
-		}
-	} else {
-		alias = d_splice_alias(inode, dentry);
-	}
+	alias = fuse_materialise_dentry(dentry, inode);
+	err = PTR_ERR(alias);
+	if (IS_ERR(alias))
+		goto out;
 
 	if (alias) {
 		dput(dentry);
-- 
1.8.1.4

