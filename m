Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49866 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934635Ab0KQRpj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:45:39 -0500
Received: by iwn35 with SMTP id 35so2373733iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:45:39 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/17] NFS: Update xdr_encode_foo() functions that we're
	keeping
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:45:34 -0500
Message-ID: <20101117174534.29177.72207.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  Move the timestamp and the sattr encoder to match the
placement convention of the other helpers, update their coding style,
and refresh their documenting comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs3xdr.c |  111 +++++++++++++++++++++++++++---------------------------
 1 files changed, 55 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 831a987..1a7e25e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -167,14 +167,6 @@ out_overflow:
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
@@ -219,52 +211,6 @@ xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
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
@@ -453,6 +399,21 @@ static void encode_nfs_fh3(struct xdr_stream *xdr, const struct nfs_fh *fh)
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
@@ -538,7 +499,45 @@ static void encode_sattr3(struct xdr_stream *xdr, const struct iattr *attr)
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
+		p = xdr_encode_hyper(p, (u64)attr->ia_size);
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
@@ -605,7 +604,7 @@ static void encode_sattrguard3(struct xdr_stream *xdr,
 	if (args->guard) {
 		p = xdr_reserve_space(xdr, 4 + 8);
 		*p++ = xdr_one;
-		xdr_encode_time3(p, &args->guardtime);
+		xdr_encode_nfstime3(p, &args->guardtime);
 	} else {
 		p = xdr_reserve_space(xdr, 4);
 		*p = xdr_zero;

