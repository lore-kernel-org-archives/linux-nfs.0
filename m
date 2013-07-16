Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:55296 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271Ab3GPNQx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jul 2013 09:16:53 -0400
Received: by mail-gg0-f174.google.com with SMTP id y3so167986ggc.33
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jul 2013 06:16:52 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] rpc_pipe: convert back to simple_dir_inode_operations
Date: Tue, 16 Jul 2013 09:16:45 -0400
Message-Id: <1373980605-31852-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that Al has fixed simple_lookup to account for the case where
sb->s_d_op is set, there's no need to keep our own special lookup op.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 406859c..017aedc 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -480,23 +480,6 @@ static const struct dentry_operations rpc_dentry_operations = {
 	.d_delete = rpc_delete_dentry,
 };
 
-/*
- * Lookup the data. This is trivial - if the dentry didn't already
- * exist, we know it is negative.
- */
-static struct dentry *
-rpc_lookup(struct inode *dir, struct dentry *dentry, unsigned int flags)
-{
-	if (dentry->d_name.len > NAME_MAX)
-		return ERR_PTR(-ENAMETOOLONG);
-	d_add(dentry, NULL);
-	return NULL;
-}
-
-static const struct inode_operations rpc_dir_inode_operations = {
-	.lookup		= rpc_lookup,
-};
-
 static struct inode *
 rpc_get_inode(struct super_block *sb, umode_t mode)
 {
@@ -509,7 +492,7 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
 	switch (mode & S_IFMT) {
 	case S_IFDIR:
 		inode->i_fop = &simple_dir_operations;
-		inode->i_op = &rpc_dir_inode_operations;
+		inode->i_op = &simple_dir_inode_operations;
 		inc_nlink(inode);
 	default:
 		break;
-- 
1.8.3.1

