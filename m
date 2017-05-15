Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52748 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965893AbdEOPS4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:18:56 -0400
Subject: [PATCH 04/21] VFS: Make get_filesystem() return the affected
 filesystem [ver #3]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 15 May 2017 16:18:52 +0100
Message-ID: <149486153283.23956.7156579413442292175.stgit@warthog.procyon.org.uk>
In-Reply-To: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make get_filesystem() return a pointer to the filesystem on which it just
got a ref.

Suggested-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/filesystems.c   |    3 ++-
 include/linux/fs.h |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/filesystems.c b/fs/filesystems.c
index cac75547d35c..591e52d23ed4 100644
--- a/fs/filesystems.c
+++ b/fs/filesystems.c
@@ -33,9 +33,10 @@ static struct file_system_type *file_systems;
 static DEFINE_RWLOCK(file_systems_lock);
 
 /* WARNING: This can be used only if we _already_ own a reference */
-void get_filesystem(struct file_system_type *fs)
+struct file_system_type *get_filesystem(struct file_system_type *fs)
 {
 	__module_get(fs->owner);
+	return fs;
 }
 
 void put_filesystem(struct file_system_type *fs)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 803e5a9b2654..bc0c054894b9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2956,7 +2956,7 @@ extern int generic_block_fiemap(struct inode *inode,
 				struct fiemap_extent_info *fieinfo, u64 start,
 				u64 len, get_block_t *get_block);
 
-extern void get_filesystem(struct file_system_type *fs);
+extern struct file_system_type *get_filesystem(struct file_system_type *fs);
 extern void put_filesystem(struct file_system_type *fs);
 extern struct file_system_type *get_fs_type(const char *name);
 extern struct super_block *get_super(struct block_device *);

