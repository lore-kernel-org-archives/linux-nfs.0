From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/22] NFS: Move and update xdr_decode_foo() functions that
	we're keeping
Date: Fri, 02 Jul 2010 13:21:23 -0400
Message-ID: <20100702172123.8761.80740.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51418 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759338Ab0GBRV0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:21:26 -0400
Received: by mail-iw0-f174.google.com with SMTP id 7so3461836iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:21:25 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c |  181 +++++++++++++++++++++++++++---------------------------
 1 files changed, 90 insertions(+), 91 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index bda8cc3..2126889 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -127,87 +127,6 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 
 
 /*
- * Common NFS XDR functions as inlines
- */
-static inline __be32 *
-xdr_decode_fhandle(__be32 *p, struct nfs_fh *fh)
-{
-	if ((fh->size = ntohl(*p++)) <= NFS3_FHSIZE) {
-		memcpy(fh->data, p, fh->size);
-		return p + XDR_QUADLEN(fh->size);
-	}
-	return NULL;
-}
-
-/*
- * Encode/decode time.
- */
-static inline __be32 *
-xdr_decode_time3(__be32 *p, struct timespec *timep)
-{
-	timep->tv_sec = ntohl(*p++);
-	timep->tv_nsec = ntohl(*p++);
-	return p;
-}
-
-static __be32 *
-xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
-{
-	unsigned int	type, major, minor;
-	umode_t		fmode;
-
-	type = ntohl(*p++);
-	if (type > NF3FIFO)
-		type = NF3NON;
-	fmode = nfs_type2fmt[type];
-	fattr->mode = (ntohl(*p++) & ~S_IFMT) | fmode;
-	fattr->nlink = ntohl(*p++);
-	fattr->uid = ntohl(*p++);
-	fattr->gid = ntohl(*p++);
-	p = xdr_decode_hyper(p, &fattr->size);
-	p = xdr_decode_hyper(p, &fattr->du.nfs3.used);
-
-	/* Turn remote device info into Linux-specific dev_t */
-	major = ntohl(*p++);
-	minor = ntohl(*p++);
-	fattr->rdev = MKDEV(major, minor);
-	if (MAJOR(fattr->rdev) != major || MINOR(fattr->rdev) != minor)
-		fattr->rdev = 0;
-
-	p = xdr_decode_hyper(p, &fattr->fsid.major);
-	fattr->fsid.minor = 0;
-	p = xdr_decode_hyper(p, &fattr->fileid);
-	p = xdr_decode_time3(p, &fattr->atime);
-	p = xdr_decode_time3(p, &fattr->mtime);
-	p = xdr_decode_time3(p, &fattr->ctime);
-
-	/* Update the mode bits */
-	fattr->valid |= NFS_ATTR_FATTR_V3;
-	return p;
-}
-
-static inline __be32 *
-xdr_decode_wcc_attr(__be32 *p, struct nfs_fattr *fattr)
-{
-	p = xdr_decode_hyper(p, &fattr->pre_size);
-	p = xdr_decode_time3(p, &fattr->pre_mtime);
-	p = xdr_decode_time3(p, &fattr->pre_ctime);
-	fattr->valid |= NFS_ATTR_FATTR_PRESIZE
-		| NFS_ATTR_FATTR_PREMTIME
-		| NFS_ATTR_FATTR_PRECTIME;
-	return p;
-}
-
-static inline __be32 *
-xdr_decode_post_op_attr(__be32 *p, struct nfs_fattr *fattr)
-{
-	if (*p++)
-		p = xdr_decode_fattr(p, fattr);
-	return p;
-}
-
-
-/*
  * Encode/decode NFSv3 basic data types
  *
  * Basic NFSv3 data types are defined in section 2.5 of RFC 1813:
@@ -417,6 +336,17 @@ static void encode_ftype3(struct xdr_stream *xdr, const u32 type)
 	encode_uint32(xdr, type);
 }
 
+static __be32 *xdr_decode_ftype3(__be32 *p, umode_t *mode)
+{
+	u32 type;
+
+	type = be32_to_cpup(p++);
+	if (type > NF3FIFO)
+		type = NF3NON;
+	*mode = nfs_type2fmt[type];
+	return p;
+}
+
 /*
  * specdata3
  *
@@ -435,6 +365,18 @@ static void encode_specdata3(struct xdr_stream *xdr, const dev_t rdev)
 	*p = cpu_to_be32(MINOR(rdev));
 }
 
+static __be32 *xdr_decode_specdata3(__be32 *p, dev_t *rdev)
+{
+	unsigned int major, minor;
+
+	major = be32_to_cpup(p++);
+	minor = be32_to_cpup(p++);
+	*rdev = MKDEV(major, minor);
+	if (MAJOR(*rdev) != major || MINOR(*rdev) != minor)
+		*rdev = 0;
+	return p;
+}
+
 /*
  * nfs_fh3
  *
@@ -452,6 +394,22 @@ static void encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh *fh)
 	xdr_encode_opaque(p, fh->data, fh->size);
 }
 
+static __be32 *xdr_decode_nfs_fh3(__be32 *p, struct nfs_fh *fh)
+{
+	u32 len;
+
+	len = be32_to_cpup(p++);
+	if (unlikely(len > NFS3_FHSIZE))
+		goto out_toolong;
+	fh->size = len;
+	memcpy(fh->data, p, len);
+	return p + XDR_QUADLEN(fh->size);
+
+out_toolong:
+	dprintk("NFS: file handle length too large: %u\n", len);
+	return NULL;
+}
+
 static int decode_nfs_fh3(struct xdr_stream *xdr, struct nfs_fh *fh)
 {
 	u32 length;
@@ -497,6 +455,13 @@ static __be32 *xdr_encode_nfstime3(__be32 *p, const struct timespec *timep)
 	return p;
 }
 
+static __be32 *xdr_decode_nfstime3(__be32 *p, struct timespec *timep)
+{
+	timep->tv_sec = be32_to_cpup(p++);
+	timep->tv_nsec = be32_to_cpup(p++);
+	return p;
+}
+
 /*
  * sattr3
  *
@@ -644,6 +609,33 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
  *		nfstime3	ctime;
  *	};
  */
+static __be32 *xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
+{
+	umode_t fmode;
+
+	p = xdr_decode_ftype3(p, &fmode);
+
+	fattr->mode	= (be32_to_cpup(p++) & ~S_IFMT) | fmode;
+	fattr->nlink	= be32_to_cpup(p++);
+	fattr->uid	= be32_to_cpup(p++);
+	fattr->gid	= be32_to_cpup(p++);
+
+	p = xdr_decode_hyper(p, &fattr->size);		/* size3 */
+	p = xdr_decode_hyper(p, &fattr->du.nfs3.used);	/* size3 */
+	p = xdr_decode_specdata3(p, &fattr->rdev);
+
+	p = xdr_decode_hyper(p, &fattr->fsid.major);
+	fattr->fsid.minor = 0;
+
+	p = xdr_decode_hyper(p, &fattr->fileid);	/* fileid3 */
+	p = xdr_decode_nfstime3(p, &fattr->atime);
+	p = xdr_decode_nfstime3(p, &fattr->mtime);
+	p = xdr_decode_nfstime3(p, &fattr->ctime);
+
+	fattr->valid |= NFS_ATTR_FATTR_V3;
+	return p;
+}
+
 static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 {
 	__be32 *p;
@@ -668,6 +660,13 @@ out_overflow:
  *		void;
  *	};
  */
+static __be32 *xdr_decode_post_op_attr(__be32 *p, struct nfs_fattr *fattr)
+{
+	if (*p++ != xdr_zero)
+		p = xdr_decode_fattr(p, fattr);
+	return p;
+}
+
 static int decode_post_op_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 {
 	__be32 *p;
@@ -698,7 +697,15 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_inline_decode(xdr, NFS3_wcc_attr_sz << 2);
 	if (unlikely(p == NULL))
 		goto out_overflow;
-	xdr_decode_wcc_attr(p, fattr);
+
+	fattr->valid |= NFS_ATTR_FATTR_PRESIZE
+		| NFS_ATTR_FATTR_PREMTIME
+		| NFS_ATTR_FATTR_PRECTIME;
+
+	p = xdr_decode_size3(p, &fattr->pre_size);
+	p = xdr_decode_nfstime3(p, &fattr->pre_mtime);
+	xdr_decode_nfstime3(p, &fattr->pre_ctime);
+
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -706,14 +713,6 @@ out_overflow:
 }
 
 /*
- * pre_op_attr
- *	union pre_op_attr switch (bool attributes_follow) {
- *	case TRUE:
- *		wcc_attr	attributes;
- *	case FALSE:
- *		void;
- *	};
- *
  * wcc_data
  *
  *	struct wcc_data {
@@ -2170,7 +2169,7 @@ __be32 *nfs3_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
 		p = xdr_decode_post_op_attr(p, entry->fattr);
 		/* In fact, a post_op_fh3: */
 		if (*p++ != xdr_zero) {
-			p = xdr_decode_fhandle(p, entry->fh);
+			p = xdr_decode_nfs_fh3(p, entry->fh);
 			if (unlikely(p == NULL))
 				goto out_truncated;
 		} else

