Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47728 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab0IQQ2s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:28:48 -0400
Received: by mail-gx0-f174.google.com with SMTP id 23so788861gxk.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:28:48 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/22] NFS: Move and update xdr_encode_foo() functions that
	we're keeping
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:28:45 -0400
Message-ID: <20100917162845.19761.58513.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c |  111 +++++++++++++++++++++++++++---------------------------
 1 files changed, 55 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index fa9b7fa..d321d2e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -137,14 +137,6 @@ xdr_decode_fhandle(__be32 *p, struct nfs_fh *fh)
  * Encode/decode time.
  */
 static inline __be32 *
-xdr_encode_time3(__be32 *p, const struct timespec *timep)
-{
-	*p++ = htonl(timep->tv_sec);
-	*p++ = htonl(timep->tv_nsec);
-	return p;
-}
-
-static inline __be32 *
 xdr_decode_time3(__be32 *p, struct timespec *timep)
 {
 	timep->tv_sec = ntohl(*p++);
@@ -189,52 +181,6 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
 }
 
 static inline __be32 *
-xdr_encode_sattr(__be32 *p, const struct iattr *attr)
-{
-	if (attr->ia_valid & ATTR_MODE) {
-		*p++ = xdr_one;
-		*p++ = htonl(attr->ia_mode & S_IALLUGO);
-	} else {
-		*p++ = xdr_zero;
-	}
-	if (attr->ia_valid & ATTR_UID) {
-		*p++ = xdr_one;
-		*p++ = htonl(attr->ia_uid);
-	} else {
-		*p++ = xdr_zero;
-	}
-	if (attr->ia_valid & ATTR_GID) {
-		*p++ = xdr_one;
-		*p++ = htonl(attr->ia_gid);
-	} else {
-		*p++ = xdr_zero;
-	}
-	if (attr->ia_valid & ATTR_SIZE) {
-		*p++ = xdr_one;
-		p = xdr_encode_hyper(p, (__u64) attr->ia_size);
-	} else {
-		*p++ = xdr_zero;
-	}
-	if (attr->ia_valid & ATTR_ATIME_SET) {
-		*p++ = xdr_two;
-		p = xdr_encode_time3(p, &attr->ia_atime);
-	} else if (attr->ia_valid & ATTR_ATIME) {
-		*p++ = xdr_one;
-	} else {
-		*p++ = xdr_zero;
-	}
-	if (attr->ia_valid & ATTR_MTIME_SET) {
-		*p++ = xdr_two;
-		p = xdr_encode_time3(p, &attr->ia_mtime);
-	} else if (attr->ia_valid & ATTR_MTIME) {
-		*p++ = xdr_one;
-	} else {
-		*p++ = xdr_zero;
-	}
-	return p;
-}
-
-static inline __be32 *
 xdr_decode_wcc_attr(__be32 *p, struct nfs_fattr *fattr)
 {
 	p = xdr_decode_hyper(p, &fattr->pre_size);
@@ -403,6 +349,21 @@ static void encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh *fh)
 }
 
 /*
+ * nfstime3
+ *
+ *	struct nfstime3 {
+ *		uint32	seconds;
+ *		uint32	nseconds;
+ *	};
+ */
+static __be32 *xdr_encode_nfstime3(__be32 *p, const struct timespec *timep)
+{
+	*p++ = cpu_to_be32(timep->tv_sec);
+	*p++ = cpu_to_be32(timep->tv_nsec);
+	return p;
+}
+
+/*
  * sattr3
  *
  *	enum time_how {
@@ -488,7 +449,45 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
 		nbytes += 8;
 	p = xdr_reserve_space(xdr, nbytes);
 
-	xdr_encode_sattr(p, attr);
+	if (attr->ia_valid & ATTR_MODE) {
+		*p++ = xdr_one;
+		*p++ = cpu_to_be32(attr->ia_mode & S_IALLUGO);
+	} else
+		*p++ = xdr_zero;
+
+	if (attr->ia_valid & ATTR_UID) {
+		*p++ = xdr_one;
+		*p++ = cpu_to_be32(attr->ia_uid);
+	} else
+		*p++ = xdr_zero;
+
+	if (attr->ia_valid & ATTR_GID) {
+		*p++ = xdr_one;
+		*p++ = cpu_to_be32(attr->ia_gid);
+	} else
+		*p++ = xdr_zero;
+
+	if (attr->ia_valid & ATTR_SIZE) {
+		*p++ = xdr_one;
+		p = xdr_encode_hyper(p, (__u64) attr->ia_size);
+	} else
+		*p++ = xdr_zero;
+
+	if (attr->ia_valid & ATTR_ATIME_SET) {
+		*p++ = xdr_two;
+		p = xdr_encode_nfstime3(p, &attr->ia_atime);
+	} else if (attr->ia_valid & ATTR_ATIME) {
+		*p++ = xdr_one;
+	} else
+		*p++ = xdr_zero;
+
+	if (attr->ia_valid & ATTR_MTIME_SET) {
+		*p++ = xdr_two;
+		xdr_encode_nfstime3(p, &attr->ia_mtime);
+	} else if (attr->ia_valid & ATTR_MTIME) {
+		*p = xdr_one;
+	} else
+		*p = xdr_zero;
 }
 
 /*
@@ -555,7 +554,7 @@ static void encode_sattrguard3(struct xdr_stream *xdr,
 	if (args->guard) {
 		p = xdr_reserve_space(xdr, 4 + 8);
 		*p++ = xdr_one;
-		xdr_encode_time3(p, &args->guardtime);
+		xdr_encode_nfstime3(p, &args->guardtime);
 	} else {
 		p = xdr_reserve_space(xdr, 4);
 		*p = xdr_zero;

