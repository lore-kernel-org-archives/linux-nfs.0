Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35860 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbbKQLxq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:46 -0500
Received: by qkda6 with SMTP id a6so1676853qkd.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:45 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 27/38] nfsd: allow filesystems to opt out of subtree checking
Date: Tue, 17 Nov 2015 06:52:49 -0500
Message-Id: <1447761180-4250-28-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we start allowing NFS to be reexported, then we have some problems
when it comes to subtree checking. In principle, we could allow it, but
it would mean encoding parent info in the filehandles and there may not
be enough space for that in a NFSv3 filehandle.

To enforce this at export upcall time, we add a new export_ops flag
that declares the filesystem ineligible for subtree checking.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 Documentation/filesystems/nfs/Exporting | 14 +++++++++++++-
 fs/nfsd/export.c                        |  6 ++++++
 include/linux/exportfs.h                |  1 +
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/nfs/Exporting b/Documentation/filesystems/nfs/Exporting
index fa636cde3907..a89b5be22703 100644
--- a/Documentation/filesystems/nfs/Exporting
+++ b/Documentation/filesystems/nfs/Exporting
@@ -160,7 +160,7 @@ contains a "flags" field that allows the filesystem to communicate to nfsd
 that it may want to do things differently when dealing with it. The
 following flags are defined:
 
-  EXPORT_OP_NOWCC
+  EXPORT_OP_NOWCC - disable NFSv3 WCC attributes on this filesystem
     RFC 1813 recommends that servers always send weak cache consistency
     (WCC) data to the client after each operation. The server should
     atomically collect attributes about the inode, do an operation on it,
@@ -174,3 +174,15 @@ following flags are defined:
     this on filesystems that have an expensive ->getattr inode operation,
     or when atomicity between pre and post operation attribute collection
     is impossible to guarantee.
+
+  EXPORT_OP_NOSUBTREECHK - disallow subtree checking on this fs
+    Many NFS operations deal with filehandles, which the server must then
+    vet to ensure that they live inside of an exported tree. When the
+    export consists of an entire filesystem, this is trivial. nfsd can just
+    ensure that the filehandle live on the filesystem. When only part of a
+    filesystem is exported however, then nfsd must walk the ancestors of the
+    inode to ensure that it's within an exported subtree. This is an
+    expensive operation and not all filesystems can support it properly.
+    This flag exempts the filesystem from subtree checking and causes
+    exportfs to get back an error if it tries to enable subtree checking
+    on it.
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 4b504edff121..295d22e8fdad 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -392,6 +392,12 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 		return -EINVAL;
 	}
 
+	if (inode->i_sb->s_export_op->flags & EXPORT_OP_NOSUBTREECHK &&
+	    *flags & NFSEXP_NOSUBTREECHECK) {
+		dprintk("%s: %s does not support subtree checking!\n",
+			__func__, inode->i_sb->s_type->name);
+		return -EINVAL;
+	}
 	return 0;
 
 }
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 600c3fccc999..5f9b5345f717 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -215,6 +215,7 @@ struct export_operations {
 	int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
 			     int nr_iomaps, struct iattr *iattr);
 #define	EXPORT_OP_NOWCC		(0x1)	/* Don't collect wcc data for NFSv3 replies */
+#define	EXPORT_OP_NOSUBTREECHK	(0x2)	/* Subtree checking is not supported! */
 	unsigned long	flags;
 };
 
-- 
2.4.3

