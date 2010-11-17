Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35769 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934828Ab0KQRor (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:44:47 -0500
Received: by gyh4 with SMTP id 4so1262325gyh.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:44:47 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/17] NFS: Move and update xdr_decode_foo() functions that
	we're keeping
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:44:42 -0500
Message-ID: <20101117174442.29177.24636.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Move the timestamp decoder to match the placement and naming
conventions of the other helpers.  Fold xdr_decode_fattr() into
decode_fattr(), which is now it's only user.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs2xdr.c |   97 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 56 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index bf80c3c..85030b9 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -89,46 +89,6 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 
 
 /*
- * Common NFS XDR functions as inlines
- */
-static inline __be32*
-xdr_decode_time(__be32 *p, struct timespec *timep)
-{
-	timep->tv_sec = ntohl(*p++);
-	/* Convert microseconds into nanoseconds */
-	timep->tv_nsec = ntohl(*p++) * 1000;
-	return p;
-}
-
-static __be32 *
-xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
-{
-	u32 rdev, type;
-	type = ntohl(*p++);
-	fattr->mode = ntohl(*p++);
-	fattr->nlink = ntohl(*p++);
-	fattr->uid = ntohl(*p++);
-	fattr->gid = ntohl(*p++);
-	fattr->size = ntohl(*p++);
-	fattr->du.nfs2.blocksize = ntohl(*p++);
-	rdev = ntohl(*p++);
-	fattr->du.nfs2.blocks = ntohl(*p++);
-	fattr->fsid.major = ntohl(*p++);
-	fattr->fsid.minor = 0;
-	fattr->fileid = ntohl(*p++);
-	p = xdr_decode_time(p, &fattr->atime);
-	p = xdr_decode_time(p, &fattr->mtime);
-	p = xdr_decode_time(p, &fattr->ctime);
-	fattr->valid |= NFS_ATTR_FATTR_V2;
-	fattr->rdev = new_decode_dev(rdev);
-	if (type == NFCHR && rdev == NFS2_FIFO_DEV) {
-		fattr->mode = (fattr->mode & ~S_IFMT) | S_IFIFO;
-		fattr->rdev = 0;
-	}
-	return p;
-}
-
-/*
  * Encode/decode NFSv2 basic data types
  *
  * Basic NFSv2 data types are defined in section 2.3 of RFC 1094:
@@ -208,6 +168,27 @@ out_overflow:
 }
 
 /*
+ * 2.3.2.  ftype
+ *
+ *	enum ftype {
+ *		NFNON = 0,
+ *		NFREG = 1,
+ *		NFDIR = 2,
+ *		NFBLK = 3,
+ *		NFCHR = 4,
+ *		NFLNK = 5
+ *	};
+ *
+ */
+static __be32 *xdr_decode_ftype(__be32 *p, u32 *type)
+{
+	*type = be32_to_cpup(p++);
+	if (unlikely(*type > NF2FIFO))
+		*type = NFBAD;
+	return p;
+}
+
+/*
  * 2.3.3.  fhandle
  *
  *	typedef opaque fhandle[FHSIZE];
@@ -269,6 +250,13 @@ static __be32 *xdr_encode_current_server_time(__be32 *p,
 	return p;
 }
 
+static __be32 *xdr_decode_time(__be32 *p, struct timespec *timep)
+{
+	timep->tv_sec = be32_to_cpup(p++);
+	timep->tv_nsec = be32_to_cpup(p++) * NSEC_PER_USEC;
+	return p;
+}
+
 /*
  * 2.3.5.  fattr
  *
@@ -292,12 +280,39 @@ static __be32 *xdr_encode_current_server_time(__be32 *p,
  */
 static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 {
+	u32 rdev, type;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS_fattr_sz << 2);
 	if (unlikely(p == NULL))
 		goto out_overflow;
-	xdr_decode_fattr(p, fattr);
+
+	fattr->valid |= NFS_ATTR_FATTR_V2;
+
+	p = xdr_decode_ftype(p, &type);
+
+	fattr->mode = be32_to_cpup(p++);
+	fattr->nlink = be32_to_cpup(p++);
+	fattr->uid = be32_to_cpup(p++);
+	fattr->gid = be32_to_cpup(p++);
+	fattr->size = be32_to_cpup(p++);
+	fattr->du.nfs2.blocksize = be32_to_cpup(p++);
+
+	rdev = be32_to_cpup(p++);
+	fattr->rdev = new_decode_dev(rdev);
+	if (type == (u32)NFCHR && rdev == (u32)NFS2_FIFO_DEV) {
+		fattr->mode = (fattr->mode & ~S_IFMT) | S_IFIFO;
+		fattr->rdev = 0;
+	}
+
+	fattr->du.nfs2.blocks = be32_to_cpup(p++);
+	fattr->fsid.major = be32_to_cpup(p++);
+	fattr->fsid.minor = 0;
+	fattr->fileid = be32_to_cpup(p++);
+
+	p = xdr_decode_time(p, &fattr->atime);
+	p = xdr_decode_time(p, &fattr->mtime);
+	xdr_decode_time(p, &fattr->ctime);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);

