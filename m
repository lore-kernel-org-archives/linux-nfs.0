Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51230 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065Ab1AUDFb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 22:05:31 -0500
Received: by mail-vw0-f46.google.com with SMTP id 16so612009vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jan 2011 19:05:31 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] NFS: nfsacl_{encode,decode} should return signed integer
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 20 Jan 2011 22:05:28 -0500
Message-ID: <20110121030528.1056.58221.stgit@matisse.1015granger.net>
In-Reply-To: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
References: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The nfsacl_encode() and nfsacl_decode() functions return negative
errno values, and each call site verifies that the returned value
is not negative.  Change the synopsis of both of these functions
to reflect this usage.

Document the synopsis and return values.

Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs_common/nfsacl.c |   32 ++++++++++++++++++++++++++------
 include/linux/nfsacl.h |    4 ++--
 2 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index fc1c525..a3e78bd 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -72,9 +72,20 @@ xdr_nfsace_encode(struct xdr_array2_desc *desc, void *elem)
 	return 0;
 }
 
-unsigned int
-nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
-	      struct posix_acl *acl, int encode_entries, int typeflag)
+/**
+ * nfsacl_encode - Encode an NFSv3 ACL
+ *
+ * @buf: destination xdr_buf to contain XDR encoded ACL
+ * @base: byte offset in xdr_buf where XDR'd ACL begins
+ * @inode: inode of file whose ACL this is
+ * @acl: posix_acl to encode
+ * @encode_entries: whether to encode ACEs as well
+ * @typeflag: ACL type: NFS_ACL_DEFAULT or zero
+ *
+ * Returns size of encoded ACL in bytes or a negative errno value.
+ */
+int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
+		  struct posix_acl *acl, int encode_entries, int typeflag)
 {
 	int entries = (acl && acl->a_count) ? max_t(int, acl->a_count, 4) : 0;
 	struct nfsacl_encode_desc nfsacl_desc = {
@@ -224,9 +235,18 @@ posix_acl_from_nfsacl(struct posix_acl *acl)
 	return 0;
 }
 
-unsigned int
-nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
-	      struct posix_acl **pacl)
+/**
+ * nfsacl_decode - Decode an NFSv3 ACL
+ *
+ * @buf: xdr_buf containing XDR'd ACL data to decode
+ * @base: byte offset in xdr_buf where XDR'd ACL begins
+ * @aclcnt: count of ACEs in decoded posix_acl
+ * @pacl: buffer in which to place decoded posix_acl
+ *
+ * Returns the length of the decoded ACL in bytes, or a negative errno value.
+ */
+int nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
+		  struct posix_acl **pacl)
 {
 	struct nfsacl_decode_desc nfsacl_desc = {
 		.desc = {
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index f321b57..fabcb1e 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -51,10 +51,10 @@ nfsacl_size(struct posix_acl *acl_access, struct posix_acl *acl_default)
 	return w;
 }
 
-extern unsigned int
+extern int
 nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 	      struct posix_acl *acl, int encode_entries, int typeflag);
-extern unsigned int
+extern int
 nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
 	      struct posix_acl **pacl);
 

