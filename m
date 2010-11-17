Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49866 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934635Ab0KQRqV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:46:21 -0500
Received: by mail-iw0-f174.google.com with SMTP id 35so2373733iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:46:20 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/17] NFS: Move and update xdr_decode_foo() functions that
	we're keeping
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:46:17 -0500
Message-ID: <20101117174617.29177.62730.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Move the timestamp decoder to match the placement and naming
conventions of the other helpers.  Fold xdr_decode_fattr() into
decode_fattr3(), which is now it's only user.  Fold
xdr_decode_wcc_attr() into decode_wcc_attr(), which is now it's only
user.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs3xdr.c |  136 +++++++++++++++++++++++++++---------------------------
 1 files changed, 67 insertions(+), 69 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 04c7936..b286980 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -127,69 +127,6 @@ static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 
 
 /*
- * Common NFS XDR functions as inlines
- */
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
-/*
  * Encode/decode NFSv3 basic data types
  *
  * Basic NFSv3 data types are defined in section 2.5 of RFC 1813:
@@ -239,6 +176,11 @@ out_overflow:
  *
  *	typedef uint64 fileid3;
  */
+static __be32 *xdr_decode_fileid3(__be32 *p, u64 *fileid)
+{
+	return xdr_decode_hyper(p, fileid);
+}
+
 static int decode_fileid3(struct xdr_stream *xdr, u64 *fileid)
 {
 	return decode_uint64(xdr, fileid);
@@ -452,6 +394,17 @@ static void encode_ftype3(struct xdr_stream *xdr, const u32 type)
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
@@ -469,6 +422,18 @@ static void encode_specdata3(struct xdr_stream *xdr, const dev_t rdev)
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
@@ -530,6 +495,13 @@ static __be32 *xdr_encode_nfstime3(__be32 *p, const struct timespec *timep)
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
@@ -678,12 +650,33 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
  */
 static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 {
+	umode_t fmode;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS3_fattr_sz << 2);
 	if (unlikely(p == NULL))
 		goto out_overflow;
-	xdr_decode_fattr(p, fattr);
+
+	p = xdr_decode_ftype3(p, &fmode);
+
+	fattr->mode = (be32_to_cpup(p++) & ~S_IFMT) | fmode;
+	fattr->nlink = be32_to_cpup(p++);
+	fattr->uid = be32_to_cpup(p++);
+	fattr->gid = be32_to_cpup(p++);
+
+	p = xdr_decode_size3(p, &fattr->size);
+	p = xdr_decode_size3(p, &fattr->du.nfs3.used);
+	p = xdr_decode_specdata3(p, &fattr->rdev);
+
+	p = xdr_decode_hyper(p, &fattr->fsid.major);
+	fattr->fsid.minor = 0;
+
+	p = xdr_decode_fileid3(p, &fattr->fileid);
+	p = xdr_decode_nfstime3(p, &fattr->atime);
+	p = xdr_decode_nfstime3(p, &fattr->mtime);
+	xdr_decode_nfstime3(p, &fattr->ctime);
+
+	fattr->valid |= NFS_ATTR_FATTR_V3;
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -730,7 +723,15 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
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
@@ -1009,10 +1010,7 @@ static void encode_write3args(struct xdr_stream *xdr,
 	p = xdr_reserve_space(xdr, 8 + 4 + 4 + 4);
 	p = xdr_encode_hyper(p, args->offset);
 	*p++ = cpu_to_be32(args->count);
-
-	BUG_ON(args->stable > NFS_FILE_SYNC);
 	*p++ = cpu_to_be32(args->stable);
-
 	*p = cpu_to_be32(args->count);
 	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
 }
@@ -2274,7 +2272,7 @@ static int decode_fsinfo3resok(struct xdr_stream *xdr,
 	result->wtmult = be32_to_cpup(p++);
 	result->dtpref = be32_to_cpup(p++);
 	p = xdr_decode_size3(p, &result->maxfilesize);
-	xdr_decode_time3(p, &result->time_delta);
+	xdr_decode_nfstime3(p, &result->time_delta);
 
 	/* ignore properties */
 	result->lease_time = 0;

