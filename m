Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f173.google.com ([209.85.160.173]:61947 "EHLO
	mail-gh0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab3GBRA6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jul 2013 13:00:58 -0400
Received: by mail-gh0-f173.google.com with SMTP id g16so2556256ghb.32
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jul 2013 10:00:58 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        bfields@fieldses.org, Alexander Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v2] rpc_pipe: set dentry operations at d_alloc time
Date: Tue,  2 Jul 2013 13:00:52 -0400
Message-Id: <1372784452-2403-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
References: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the way these get set is a little convoluted. If the dentry is
allocated via lookup from userland, then it gets set by simple_lookup.
If it gets allocated when the kernel is populating the directory, then
it gets set via __rpc_lookup_create_exclusive, which has to check
whether they might already be set. Between both of these, this ensures
that all dentries have their d_op pointer set.

Instead of doing that, just have them set at d_alloc time by pointing
sb->s_d_op at them. With that change, we no longer want the lookup op
to set them, so we must move to using our own lookup routine.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index a816b3a..ca5ad70d 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -480,6 +480,23 @@ static const struct dentry_operations rpc_dentry_operations = {
 	.d_delete = rpc_delete_dentry,
 };
 
+/*
+ * Lookup the data. This is trivial - if the dentry didn't already
+ * exist, we know it is negative.
+ */
+static struct dentry *
+rpc_lookup(struct inode *dir, struct dentry *dentry, unsigned int flags)
+{
+	if (dentry->d_name.len > NAME_MAX)
+		return ERR_PTR(-ENAMETOOLONG);
+	d_add(dentry, NULL);
+	return NULL;
+}
+
+const struct inode_operations rpc_dir_inode_operations = {
+	.lookup		= rpc_lookup,
+};
+
 static struct inode *
 rpc_get_inode(struct super_block *sb, umode_t mode)
 {
@@ -492,7 +509,7 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
 	switch (mode & S_IFMT) {
 	case S_IFDIR:
 		inode->i_fop = &simple_dir_operations;
-		inode->i_op = &simple_dir_inode_operations;
+		inode->i_op = &rpc_dir_inode_operations;
 		inc_nlink(inode);
 	default:
 		break;
@@ -666,11 +683,8 @@ static struct dentry *__rpc_lookup_create_exclusive(struct dentry *parent,
 		if (!dentry)
 			return ERR_PTR(-ENOMEM);
 	}
-	if (dentry->d_inode == NULL) {
-		if (!dentry->d_op)
-			d_set_d_op(dentry, &rpc_dentry_operations);
+	if (dentry->d_inode == NULL)
 		return dentry;
-	}
 	dput(dentry);
 	return ERR_PTR(-EEXIST);
 }
@@ -1117,6 +1131,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
 	sb->s_magic = RPCAUTH_GSSMAGIC;
 	sb->s_op = &s_ops;
+	sb->s_d_op = &rpc_dentry_operations;
 	sb->s_time_gran = 1;
 
 	inode = rpc_get_inode(sb, S_IFDIR | S_IRUGO | S_IXUGO);
-- 
1.8.1.4

