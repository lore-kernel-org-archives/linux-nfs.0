Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932212Ab0I3SQ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:28 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 12/17] autofs4: cleanup inode operations
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>
Date: Thu, 30 Sep 2010 19:15:57 +0100
Message-ID: <20100930181557.30939.78979.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

Since the use of ->follow_link() has been eliminated there is no
need to separate the indirect and direct inode operations.

Signed-off-by: Ian Kent <raven@themaw.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/autofs4/autofs_i.h |    3 ---
 fs/autofs4/inode.c    |    4 +---
 fs/autofs4/root.c     |   15 ---------------
 3 files changed, 1 insertions(+), 21 deletions(-)

diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index cb86036..8710878 100644
--- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -201,9 +201,6 @@ void autofs_dev_ioctl_exit(void);
 
 extern const struct inode_operations autofs4_symlink_inode_operations;
 extern const struct inode_operations autofs4_dir_inode_operations;
-extern const struct inode_operations autofs4_root_inode_operations;
-extern const struct inode_operations autofs4_indirect_root_inode_operations;
-extern const struct inode_operations autofs4_direct_root_inode_operations;
 extern const struct file_operations autofs4_dir_operations;
 extern const struct file_operations autofs4_root_operations;
 
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index c6e75b3..80cdffd 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -326,9 +326,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 		__managed_dentry_set_managed(root);
 
 	root_inode->i_fop = &autofs4_root_operations;
-	root_inode->i_op = autofs_type_trigger(sbi->type) ?
-			&autofs4_direct_root_inode_operations :
-			&autofs4_indirect_root_inode_operations;
+	root_inode->i_op = &autofs4_dir_inode_operations;
 
 	/* Couldn't this be tested earlier? */
 	if (sbi->max_proto < AUTOFS_MIN_PROTO_VERSION ||
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index 77257dd..2856a0c 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -52,21 +52,6 @@ const struct file_operations autofs4_dir_operations = {
 	.llseek		= dcache_dir_lseek,
 };
 
-const struct inode_operations autofs4_indirect_root_inode_operations = {
-	.lookup		= autofs4_lookup,
-	.unlink		= autofs4_dir_unlink,
-	.symlink	= autofs4_dir_symlink,
-	.mkdir		= autofs4_dir_mkdir,
-	.rmdir		= autofs4_dir_rmdir,
-};
-
-const struct inode_operations autofs4_direct_root_inode_operations = {
-	.lookup		= autofs4_lookup,
-	.unlink		= autofs4_dir_unlink,
-	.mkdir		= autofs4_dir_mkdir,
-	.rmdir		= autofs4_dir_rmdir,
-};
-
 const struct inode_operations autofs4_dir_inode_operations = {
 	.lookup		= autofs4_lookup,
 	.unlink		= autofs4_dir_unlink,

