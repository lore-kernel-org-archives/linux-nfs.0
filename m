From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/22] NFS: Move and update xdr_encode_foo() functions that
	we're keeping
Date: Fri, 02 Jul 2010 13:20:47 -0400
Message-ID: <20100702172047.8761.57512.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51418 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759338Ab0GBRUt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:20:49 -0400
Received: by mail-iw0-f174.google.com with SMTP id 7so3461836iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:20:48 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c |  111 +++++++++++++++++++++++++++---------------------------
 1 files changed, 55 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 705d019..fbeac15 100644
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
@@ -404,6 +350,21 @@ static void encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh *fh)
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
@@ -490,7 +451,45 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
 	p = xdr_reserve_space(xdr, nbytes);
 	BUG_ON(unlikely(p == NULL));
 
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
@@ -558,7 +557,7 @@ static void encode_sattrguard3(struct xdr_stream *xdr,
 		p = xdr_reserve_space(xdr, 4 + 8);
 		BUG_ON(unlikely(p == NULL));
 		*p++ = xdr_one;
-		xdr_encode_time3(p, &args->guardtime);
+		xdr_encode_nfstime3(p, &args->guardtime);
 	} else {
 		p = xdr_reserve_space(xdr, 4);
 		BUG_ON(unlikely(p == NULL));

