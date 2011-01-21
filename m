Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51230 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369Ab1AUDFl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 22:05:41 -0500
Received: by mail-vw0-f46.google.com with SMTP id 16so612009vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jan 2011 19:05:41 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: Prevent memory allocation failure in nfsacl_encode()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 20 Jan 2011 22:05:38 -0500
Message-ID: <20110121030538.1056.53327.stgit@matisse.1015granger.net>
In-Reply-To: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
References: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfsacl_encode() allocates memory in certain cases.  This of course
is not guaranteed to work.

Since commit 9f06c719 "SUNRPC: New xdr_streams XDR encoder API", the
kernel's XDR encoders can't return a result indicating possibly a
failure, so a memory allocation failure in nfsacl_encode() has become
fatal (ie, the XDR code Oopses) in some cases.

However, the allocated memory is a tiny fixed amount, on the order
of 40-50 bytes.  We can easily use a stack-allocated buffer for
this, with only a wee bit of nose-holding.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3acl.c          |    4 ++--
 fs/nfs_common/nfsacl.c    |   22 +++++++++++++++-------
 fs/posix_acl.c            |   17 +++++++++++++----
 include/linux/posix_acl.h |    1 +
 4 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 9f88c5f..2743427 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -311,8 +311,8 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	if (!nfs_server_capable(inode, NFS_CAP_ACLS))
 		goto out;
 
-	/* We are doing this here, because XDR marshalling can only
-	   return -ENOMEM. */
+	/* We are doing this here because XDR marshalling does not
+	 * return any results, it BUGs. */
 	status = -ENOSPC;
 	if (acl != NULL && acl->a_count > NFS_ACL_MAX_ENTRIES)
 		goto out;
diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index a3e78bd..84c27d6 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -42,6 +42,11 @@ struct nfsacl_encode_desc {
 	gid_t gid;
 };
 
+struct nfsacl_simple_acl {
+	struct posix_acl acl;
+	struct posix_acl_entry ace[4];
+};
+
 static int
 xdr_nfsace_encode(struct xdr_array2_desc *desc, void *elem)
 {
@@ -99,17 +104,22 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 		.uid = inode->i_uid,
 		.gid = inode->i_gid,
 	};
+	struct nfsacl_simple_acl aclbuf;
 	int err;
-	struct posix_acl *acl2 = NULL;
 
 	if (entries > NFS_ACL_MAX_ENTRIES ||
 	    xdr_encode_word(buf, base, entries))
 		return -EINVAL;
 	if (encode_entries && acl && acl->a_count == 3) {
-		/* Fake up an ACL_MASK entry. */
-		acl2 = posix_acl_alloc(4, GFP_KERNEL);
-		if (!acl2)
-			return -ENOMEM;
+		struct posix_acl *acl2 = &aclbuf.acl;
+
+		/* Avoid the use of posix_acl_alloc().  nfsacl_encode() is
+		 * invoked in contexts where a memory allocation failure is
+		 * fatal.  Fortunately this fake ACL is small enough to
+		 * construct on the stack. */
+		memset(acl2, 0, sizeof(acl2));
+		posix_acl_init(acl2, 4);
+
 		/* Insert entries in canonical order: other orders seem
 		 to confuse Solaris VxFS. */
 		acl2->a_entries[0] = acl->a_entries[0];  /* ACL_USER_OBJ */
@@ -120,8 +130,6 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 		nfsacl_desc.acl = acl2;
 	}
 	err = xdr_encode_array2(buf, base + 4, &nfsacl_desc.desc);
-	if (acl2)
-		posix_acl_release(acl2);
 	if (!err)
 		err = 8 + nfsacl_desc.desc.elem_size *
 			  nfsacl_desc.desc.array_len;
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 39df95a..b1cf6bf 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -22,6 +22,7 @@
 
 #include <linux/errno.h>
 
+EXPORT_SYMBOL(posix_acl_init);
 EXPORT_SYMBOL(posix_acl_alloc);
 EXPORT_SYMBOL(posix_acl_clone);
 EXPORT_SYMBOL(posix_acl_valid);
@@ -32,6 +33,16 @@ EXPORT_SYMBOL(posix_acl_chmod_masq);
 EXPORT_SYMBOL(posix_acl_permission);
 
 /*
+ * Init a fresh posix_acl
+ */
+void
+posix_acl_init(struct posix_acl *acl, int count)
+{
+	atomic_set(&acl->a_refcount, 1);
+	acl->a_count = count;
+}
+
+/*
  * Allocate a new ACL with the specified number of entries.
  */
 struct posix_acl *
@@ -40,10 +51,8 @@ posix_acl_alloc(int count, gfp_t flags)
 	const size_t size = sizeof(struct posix_acl) +
 	                    count * sizeof(struct posix_acl_entry);
 	struct posix_acl *acl = kmalloc(size, flags);
-	if (acl) {
-		atomic_set(&acl->a_refcount, 1);
-		acl->a_count = count;
-	}
+	if (acl)
+		posix_acl_init(acl, count);
 	return acl;
 }
 
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index d68283a..54211c1 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -71,6 +71,7 @@ posix_acl_release(struct posix_acl *acl)
 
 /* posix_acl.c */
 
+extern void posix_acl_init(struct posix_acl *, int);
 extern struct posix_acl *posix_acl_alloc(int, gfp_t);
 extern struct posix_acl *posix_acl_clone(const struct posix_acl *, gfp_t);
 extern int posix_acl_valid(const struct posix_acl *);

